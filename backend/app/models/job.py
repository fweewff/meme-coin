from enum import Enum as PyEnum

from sqlalchemy import Column, DateTime, Enum as SQLAEnum, String, Text, func
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class JobStatusEnum(str, PyEnum):
    queued = "queued"
    processing = "processing"
    completed = "completed"
    failed = "failed"


class TuningJob(Base):
    """Persisted metadata for AI tuning jobs."""

    __tablename__ = "tuning_jobs"

    job_id = Column(String(64), primary_key=True, index=True)
    user_id = Column(String(64), nullable=False, index=True)
    vehicle_profile_id = Column(String(64), nullable=False)
    status = Column(SQLAEnum(JobStatusEnum, name="job_status"), nullable=False, default=JobStatusEnum.queued)
    original_s3_key = Column(String(255), nullable=False)
    modified_s3_key = Column(String(255), nullable=True)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # TODO(security): Add audit fields and ensure job ownership validated per request.
