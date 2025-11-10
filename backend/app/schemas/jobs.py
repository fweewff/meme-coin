from pydantic import BaseModel


class UploadResponse(BaseModel):
    job_id: str
    message: str = "Upload accepted"


class JobStatusResponse(BaseModel):
    job_id: str
    status: str
    detail: str | None = None
