from pydantic import BaseModel
from typing import List, Dict


class Meal(BaseModel):
    id: str
    name: str
    ingredients: List[str]
    nutrition: Dict[str, float]  # calories, protein, carbs, fat, etc.