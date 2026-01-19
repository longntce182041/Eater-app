"""
Tests for meal plan endpoints.
"""
import pytest
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_generate_daily_meal_plan():
    """Test generating a daily meal plan."""
    request_data = {
        "user_id": "test_user_123",
        "target_calories": 2000,
        "diet_type": "standard",
        "plan_type": "daily",
    }

    response = client.post("/api/v1/meal-plans/generate", json=request_data)
    assert response.status_code == 201
    data = response.json()
    assert data["plan_type"] == "daily"
    assert "data" in data
    assert data["data"]["target_calories"] == 2000


def test_generate_weekly_meal_plan():
    """Test generating a weekly meal plan."""
    request_data = {
        "user_id": "test_user_123",
        "target_calories": 2000,
        "diet_type": "mediterranean",
        "plan_type": "weekly",
    }

    response = client.post("/api/v1/meal-plans/generate", json=request_data)
    assert response.status_code == 201
    data = response.json()
    assert data["plan_type"] == "weekly"


def test_generate_meal_plan_with_restrictions():
    """Test generating meal plan with dietary restrictions."""
    request_data = {
        "user_id": "test_user_123",
        "target_calories": 1800,
        "diet_type": "vegetarian",
        "plan_type": "daily",
        "dietary_restrictions": ["gluten", "nuts"],
    }

    response = client.post("/api/v1/meal-plans/generate", json=request_data)
    assert response.status_code == 201


def test_invalid_calorie_target():
    """Test validation for invalid calorie target."""
    request_data = {
        "user_id": "test_user_123",
        "target_calories": 500,  # Too low
        "diet_type": "standard",
        "plan_type": "daily",
    }

    response = client.post("/api/v1/meal-plans/generate", json=request_data)
    assert response.status_code == 422  # Validation error
