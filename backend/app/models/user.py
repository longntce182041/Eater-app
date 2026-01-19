"""
User database model.
"""
from sqlalchemy import Boolean, Column, Float, Integer, String, Enum
from sqlalchemy.dialects.postgresql import ARRAY

from app.core.constants import ActivityLevel, DietType, Gender, HealthGoal
from app.models.base import Base


class User(Base):
    """User database model."""

    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    username = Column(String, unique=True, index=True, nullable=True)
    is_active = Column(Boolean, default=True)

    # Profile data
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)
    weight_kg = Column(Float, nullable=True)
    height_cm = Column(Float, nullable=True)
    activity_level = Column(String, nullable=True)
    health_goal = Column(String, nullable=True)
    diet_type = Column(String, nullable=True)

    # Health data
    allergies = Column(ARRAY(String), nullable=True)
    intolerances = Column(ARRAY(String), nullable=True)
    medical_conditions = Column(ARRAY(String), nullable=True)

    # Calculated values (cached)
    bmr = Column(Float, nullable=True)
    tdee = Column(Float, nullable=True)
    target_calories = Column(Integer, nullable=True)
