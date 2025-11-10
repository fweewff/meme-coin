from __future__ import annotations

from dataclasses import dataclass


@dataclass
class JobStatus:
    job_id: str
    status: str
    detail: str | None = None


class AIJobService:
    """Placeholder for AI/ML processing pipeline integration."""

    async def dispatch_job(self, job_id: str, original_key: str) -> JobStatus:
        """Submit AI processing job and return job identifier."""
        # TODO(ai): Integrate with async task queue (Celery, Arq, etc.) and AI model execution.
        return JobStatus(job_id=job_id, status="queued", detail="Awaiting processing")

    async def get_status(self, job_id: str) -> JobStatus:
        """Retrieve AI job status by identifier."""
        # TODO(ai): Query task queue/database for canonical job state.
        return JobStatus(job_id=job_id, status="processing")

    async def finalize_job(self, job_id: str, modified_key: str) -> None:
        """Mark job as complete after AI service generates modified binary."""
        # TODO(ai): Persist job completion records, attach metadata, handle audit logging.
        raise NotImplementedError("AI job finalization logic should be implemented here.")
