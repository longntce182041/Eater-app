"""
Meal-related database models.
"""
from sqlalchemy import (
    Boolean,
    Column,
    Date,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import ARRAY, JSONB
from sqlalchemy.orm import relationship

from app.models.base import Base


class MealPlan(Base):
    """Meal plan database model."""

    __tablename__ = "meal_plans"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    plan_type = Column(String, nullable=False)  # daily or weekly
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)

    # Targets
    target_calories = Column(Integer, nullable=False)
    diet_type = Column(String, nullable=True)

    # Metadata
    is_ai_generated = Column(Boolean, default=True)
    optimization_status = Column(String, nullable=True)

    # Relationships
    meals = relationship("Meal", back_populates="meal_plan")


class Meal(Base):
    """Individual meal in a meal plan."""

    __tablename__ = "meals"

    id = Column(String, primary_key=True, index=True)
    meal_plan_id = Column(
        String,
        ForeignKey("meal_plans.id"),
        nullable=False,
        index=True,
    )
    meal_type = Column(String, nullable=False)  # breakfast, lunch, dinner, snack
    scheduled_date = Column(Date, nullable=False)

    # Meal details
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    recipe_id = Column(String, nullable=True)

    # Nutrition
    calories = Column(Integer, nullable=True)
    protein_g = Column(Float, nullable=True)
    carbs_g = Column(Float, nullable=True)
    fat_g = Column(Float, nullable=True)

    # Relationships
    meal_plan = relationship("MealPlan", back_populates="meals")


class Recipe(Base):
    """Recipe database model."""

    __tablename__ = "recipes"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)

    # Categorization
    categories = Column(ARRAY(String), nullable=True)
    cuisine_types = Column(ARRAY(String), nullable=True)
    dietary_labels = Column(ARRAY(String), nullable=True)

    # Timing
    prep_time_minutes = Column(Integer, nullable=True)
    cook_time_minutes = Column(Integer, nullable=True)
    servings = Column(Integer, default=1)
    difficulty = Column(String, nullable=True)

    # Nutrition per serving
    calories = Column(Integer, nullable=True)
    protein_g = Column(Float, nullable=True)
    carbs_g = Column(Float, nullable=True)
    fat_g = Column(Float, nullable=True)
    fiber_g = Column(Float, nullable=True)

    # Recipe data
    ingredients = Column(JSONB, nullable=True)
    instructions = Column(ARRAY(String), nullable=True)
