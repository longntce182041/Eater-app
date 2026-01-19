"""
Health check endpoint.
"""
from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check():
    """
    Health check endpoint.

    Returns service status and version.
    """
    return {
        "status": "healthy",
        "service": "AI Meal Planning Service",
        "version": "1.0.0",
    }


@router.get("/ready")
async def readiness_check():
    """
    Readiness check for Kubernetes probes.

    Returns whether the service is ready to accept requests.
    """
    # TODO: Add checks for database connection, external services, etc.
    return {
        "ready": True,
        "checks": {
            "database": "ok",
            "cache": "ok",
        },
    }
