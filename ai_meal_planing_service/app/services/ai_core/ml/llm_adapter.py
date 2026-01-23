from typing import Any, Dict


class LLMAdapter:
    """Adapter for external LLM APIs (OpenAI, local LLM, etc.)."""

    async def suggest_meal_variations(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """Use an LLM to suggest variations or explanations."""
        raise NotImplementedError