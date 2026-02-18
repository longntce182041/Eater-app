# File: d:\SP26\WDP\code base\Eater-app\ai_meal_planing_service\app\domain\value_objects\macro_split.py

from pydantic import BaseModel, Field
from typing import Optional


class MacroSplit(BaseModel):
    """Value object representing macronutrient split."""
    
    protein_g: float = Field(..., ge=0, description="Protein in grams")
    carbs_g: float = Field(..., ge=0, description="Carbohydrates in grams")
    fat_g: float = Field(..., ge=0, description="Fat in grams")
    
    protein_percent: Optional[float] = Field(None, ge=0, le=100, description="Protein percentage")
    carbs_percent: Optional[float] = Field(None, ge=0, le=100, description="Carbs percentage")
    fat_percent: Optional[float] = Field(None, ge=0, le=100, description="Fat percentage")
    
    @property
    def total_calories(self) -> float:
        """Calculate total calories from macros."""
        return (self.protein_g * 4) + (self.carbs_g * 4) + (self.fat_g * 9)
    
    def validate_split(self) -> bool:
        """Validate that percentages sum to 100 (with tolerance)."""
        if all([self.protein_percent, self.carbs_percent, self.fat_percent]):
            total = self.protein_percent + self.carbs_percent + self.fat_percent
            return 99 <= total <= 101
        return True