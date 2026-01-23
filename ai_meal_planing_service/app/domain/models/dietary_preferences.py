from pydantic import BaseModel
from typing import List


class DietaryPreferences(BaseModel):
    user_id: str
    dietary_style: str  # e.g. "vegan", "keto", "balanced"
    allergies: List[str] = []
    dislikes: List[str] = []