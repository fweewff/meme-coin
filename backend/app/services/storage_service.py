from __future__ import annotations

from dataclasses import dataclass
from typing import BinaryIO

import boto3
from botocore.client import Config

from app.core.config.settings import get_settings


@dataclass
class FileMetadata:
    job_id: str
    checksum: str  # TODO(security): Replace with cryptographic hash verification.
    content_type: str
    size_bytes: int


class S3StorageService:
    """Handles secure upload/download of ECU binaries from S3-compatible storage."""

    def __init__(self) -> None:
        settings = get_settings()
        session = boto3.session.Session(
            aws_access_key_id=settings.aws_access_key_id or None,
            aws_secret_access_key=settings.aws_secret_access_key or None,
        )

        # TODO(security): Enforce TLS 1.2+, signing, and bucket policies in infrastructure.
        self._client = session.client(
            service_name="s3",
            endpoint_url=settings.s3_endpoint_url,
            config=Config(signature_version="s3v4"),
        )
        self._bucket_original = settings.s3_bucket_original
        self._bucket_modified = settings.s3_bucket_modified

    def upload_original(self, file_obj: BinaryIO, metadata: FileMetadata) -> str:
        """Upload original ECU binary."""
        key = f"{metadata.job_id}/original.bin"

        self._client.upload_fileobj(
            Fileobj=file_obj,
            Bucket=self._bucket_original,
            Key=key,
            ExtraArgs={
                "ContentType": metadata.content_type,
                "Metadata": {
                    "checksum": metadata.checksum,
                    "size": str(metadata.size_bytes),
                },
            },
        )

        return key

    def upload_modified(self, file_obj: BinaryIO, metadata: FileMetadata) -> str:
        """Upload AI-modified ECU binary."""
        key = f"{metadata.job_id}/modified.bin"
        self._client.upload_fileobj(
            Fileobj=file_obj,
            Bucket=self._bucket_modified,
            Key=key,
            ExtraArgs={
                "ContentType": metadata.content_type,
                "Metadata": {"checksum": metadata.checksum},
            },
        )
        return key

    def download_modified(self, job_id: str) -> bytes:
        """Download AI-modified ECU binary."""
        key = f"{job_id}/modified.bin"
        response = self._client.get_object(Bucket=self._bucket_modified, Key=key)

        # TODO(security): Validate checksum + signature before returning to client.
        return response["Body"].read()
