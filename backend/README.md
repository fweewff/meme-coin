# AI-Tuner Backend Skeleton

This directory contains the FastAPI-based backend skeleton for the AI-Tuner application. It follows a modular, clean architecture layout:

- `app/core`: configuration and low-level infrastructure code
- `app/services`: domain services for storage and AI job orchestration
- `app/api`: FastAPI routers exposing the HTTP interface
- `app/models`: SQLAlchemy models for persistence
- `app/schemas`: Pydantic models for data validation

## Getting Started

Install dependencies and run the server (Poetry recommended):

```bash
cd backend
poetry install
poetry run uvicorn app.main:app --reload
```

Ensure the following environment variables are set before running:

- `DATABASE_DSN` (async Postgres connection string)
- `S3_ENDPOINT`, `S3_BUCKET_ORIGINAL`, `S3_BUCKET_MODIFIED`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `SECRET_KEY` (>= 32 chars)

## Security TODOs

- Replace placeholder auth with JWT/OAuth2 and enforce HTTPS only.
- Validate file integrity (checksums/signatures) before and after AI processing.
- Harden storage buckets with least privilege IAM policies and server-side encryption.
