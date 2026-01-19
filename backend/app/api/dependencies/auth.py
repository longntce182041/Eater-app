"""
API Dependencies

Common dependencies for API endpoints including authentication,
database sessions, and service instances.
"""
from typing import Generator, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.security import decode_access_token

# HTTP Bearer token security scheme
security = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
) -> Optional[dict]:
    """
    Dependency to get the current authenticated user.

    Args:
        credentials: HTTP Bearer credentials

    Returns:
        User data from JWT token

    Raises:
        HTTPException: If token is invalid or missing
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    payload = decode_access_token(token)

    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return payload


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
) -> Optional[dict]:
    """
    Dependency to optionally get the current user.

    Returns None if not authenticated instead of raising an exception.
    Useful for endpoints that work with or without authentication.
    """
    if credentials is None:
        return None

    payload = decode_access_token(credentials.credentials)
    return payload


# Database session dependency placeholder
# TODO: Implement actual database session management
async def get_db() -> Generator:
    """
    Dependency to get a database session.

    Yields:
        Database session
    """
    # TODO: Implement actual database connection
    # async with AsyncSession() as session:
    #     yield session
    yield None
