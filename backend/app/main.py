from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.routes import router as v1_router
from app.core.config.settings import get_settings


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Application startup/shutdown lifecycle."""
    settings = get_settings()
    # TODO: Initialize connections (task queues, metrics exporters) here.
    yield
    # TODO: Gracefully shutdown initialized resources.


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title="AI-Tuner Backend",
        version="0.1.0",
        lifespan=lifespan,
        docs_url=f"{settings.api_prefix}/docs",
        redoc_url=f"{settings.api_prefix}/redoc",
        openapi_url=f"{settings.api_prefix}/openapi.json",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # TODO(security): Restrict to trusted origins.
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(v1_router, prefix=settings.api_prefix, tags=["ECU Tuning"])

    return app


app = create_app()
