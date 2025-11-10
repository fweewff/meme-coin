from __future__ import annotations

from uuid import uuid4

from botocore.exceptions import ClientError
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.db import get_db_session
from app.schemas.jobs import JobStatusResponse, UploadResponse
from app.services.ai_job_service import AIJobService
from app.services.storage_service import FileMetadata, S3StorageService

router = APIRouter()


@router.post(
    "/upload-original",
    response_model=UploadResponse,
    status_code=status.HTTP_202_ACCEPTED,
)
async def upload_original_binary(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db_session),
) -> UploadResponse:
    """
    Receive an original ECU binary from the mobile client, persist it to storage,
    and enqueue AI modification job.
    """
    # TODO(security): Enforce auth (Bearer token), RBAC, and per-user job quotas.
    if not file.filename:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="File required.")

    storage_service = S3StorageService()
    job_id = str(uuid4())

    metadata = FileMetadata(
        job_id=job_id,
        checksum="pending",  # TODO(security): Compute SHA-256 checksum and sign metadata.
        content_type=file.content_type or "application/octet-stream",
        size_bytes=0,  # TODO: Track stream size securely.
    )

    original_key = storage_service.upload_original(file.file, metadata)

    ai_service = AIJobService()
    job_status = await ai_service.dispatch_job(job_id=metadata.job_id, original_key=original_key)

    # TODO: Persist job record & link to authenticated user using `db`.
    return UploadResponse(job_id=job_status.job_id)


@router.get(
    "/job-status/{job_id}",
    response_model=JobStatusResponse,
)
async def get_job_status(job_id: str) -> JobStatusResponse:
    """Return current processing state of an AI tuning job."""
    ai_service = AIJobService()
    status_ = await ai_service.get_status(job_id)
    return JobStatusResponse(job_id=status_.job_id, status=status_.status, detail=status_.detail)


@router.get(
    "/download-mod/{job_id}",
    response_description="Modified ECU binary",
)
async def download_modified_binary(job_id: str) -> StreamingResponse:
    """
    Stream the AI-modified ECU binary back to the mobile client for flashing.
    """
    storage_service = S3StorageService()

    try:
        data = storage_service.download_modified(job_id)
    except ClientError as exc:
        error_code = exc.response.get("Error", {}).get("Code") if exc.response else None
        if error_code == "NoSuchKey":
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Modified file not found.",
            ) from exc
        raise

    # TODO(security): Perform final checksum verification and attach integrity headers.
    return StreamingResponse(
        content=iter([data]),
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{job_id}-modified.bin"',
        },
    )
