from typing import Any, Dict
import httpx

from app.core.config import settings


class BackendClient:
    def __init__(self) -> None:
        self._client = httpx.AsyncClient(
            base_url=settings.BACKEND_BASE_URL,
            timeout=settings.BACKEND_TIMEOUT_SECONDS,
        )

    async def get_user_profile(self, user_id: str) -> Dict[str, Any]:
        # TODO: call backend /profile endpoint
        raise NotImplementedError

    async def get_dietary_preferences(self, user_id: str) -> Dict[str, Any]:
        # TODO: call backend /preferences endpoint
        raise NotImplementedError

    async def get_candidate_recipes(self, params: Dict[str, Any]) -> Dict[str, Any]:
        # TODO: call backend /recipes endpoint
        raise NotImplementedError