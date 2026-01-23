from fastapi import APIRouter

router = APIRouter()

@router.get("/", summary="Healthcheck")
async def healthcheck() -> dict:
    return {"status": "ok"}