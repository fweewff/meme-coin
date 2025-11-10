from typing import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config.settings import get_settings


def get_engine():
    settings = get_settings()
    # TODO(security): Require SSL for production database connections.
    return create_async_engine(str(settings.database_dsn), future=True, echo=False)


SessionLocal = async_sessionmaker(
    bind=get_engine(),
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db_session() -> AsyncIterator[AsyncSession]:
    """FastAPI dependency for database session lifespan."""
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
