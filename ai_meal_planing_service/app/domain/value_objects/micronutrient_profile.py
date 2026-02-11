# File: d:\SP26\WDP\code base\Eater-app\ai_meal_planing_service\app\domain\value_objects\micronutrient_profile.py

from pydantic import BaseModel, Field
from typing import Optional


class MicronutrientProfile(BaseModel):
    """Value object for micronutrient targets and tracking."""
    
    # Vitamins
    vitamin_a_mcg: Optional[float] = Field(None, ge=0, description="Vitamin A in micrograms")
    vitamin_c_mg: Optional[float] = Field(None, ge=0, description="Vitamin C in milligrams")
    vitamin_d_mcg: Optional[float] = Field(None, ge=0, description="Vitamin D in micrograms")
    vitamin_e_mg: Optional[float] = Field(None, ge=0, description="Vitamin E in milligrams")
    
    # Minerals
    calcium_mg: Optional[float] = Field(None, ge=0, description="Calcium in milligrams")
    iron_mg: Optional[float] = Field(None, ge=0, description="Iron in milligrams")
    magnesium_mg: Optional[float] = Field(None, ge=0, description="Magnesium in milligrams")
    potassium_mg: Optional[float] = Field(None, ge=0, description="Potassium in milligrams")
    sodium_mg: Optional[float] = Field(None, ge=0, description="Sodium in milligrams")
    
    # Other
    fiber_g: Optional[float] = Field(None, ge=0, description="Fiber in grams")
    
    def get_adequacy_percentage(self, consumed: 'MicronutrientProfile') -> dict:
        """Calculate what percentage of targets have been met."""
        adequacy = {}
        for field in self.__fields__:
            target = getattr(self, field)
            consumed_val = getattr(consumed, field)
            if target and consumed_val:
                adequacy[field] = round((consumed_val / target) * 100, 2)
        return adequacy