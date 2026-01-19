# AI Meal Planning Service

A Python FastAPI backend service for AI-powered meal planning with rule-based AI algorithms.

## Architecture

```
backend/
├── app/
│   ├── api/
│   │   ├── endpoints/          # REST API endpoints
│   │   │   ├── health.py       # Health check endpoint
│   │   │   ├── users.py        # User profile endpoints
│   │   │   ├── meal_plans.py   # Meal plan generation endpoints
│   │   │   └── nutrition.py    # Nutrition calculation endpoints
│   │   └── dependencies/       # API dependencies (auth, db)
│   │
│   ├── core/                   # Core configuration
│   │   ├── config.py           # Environment settings
│   │   ├── security.py         # JWT & password utilities
│   │   └── constants.py        # Application constants
│   │
│   ├── services/               # Business logic layer
│   │   ├── ai/                 # AI Core modules
│   │   │   ├── profile_analyzer.py      # Analyze user profile & preferences
│   │   │   ├── metabolism_calculator.py # BMR & TDEE calculation
│   │   │   ├── nutrition_calculator.py  # Nutrition values calculation
│   │   │   └── meal_plan_generator.py   # Generate & optimize meal plans
│   │   │
│   │   ├── user_service.py     # User-related business logic
│   │   └── meal_service.py     # Meal-related business logic
│   │
│   ├── repositories/           # Data access layer
│   │   ├── base.py             # Base repository interface
│   │   ├── user_repository.py  # User data operations
│   │   └── meal_repository.py  # Meal data operations
│   │
│   ├── models/                 # Database models (SQLAlchemy)
│   │   ├── base.py             # Base model class
│   │   ├── user.py             # User model
│   │   └── meal.py             # Meal-related models
│   │
│   ├── schemas/                # Pydantic schemas (request/response)
│   │   ├── user.py             # User schemas
│   │   ├── meal_plan.py        # Meal plan schemas
│   │   └── nutrition.py        # Nutrition schemas
│   │
│   └── main.py                 # FastAPI application entry point
│
├── tests/                      # Test suite
│   ├── api/                    # API endpoint tests
│   ├── services/               # Service layer tests
│   └── repositories/           # Repository tests
│
├── pyproject.toml              # Project dependencies (Poetry)
├── requirements.txt            # Pip requirements
└── README.md                   # This file
```

## AI Core Modules

### 1. Profile Analyzer (`services/ai/profile_analyzer.py`)
- Analyzes user health data, dietary restrictions, and preferences
- Identifies nutritional requirements based on health goals
- Categorizes users by activity level and dietary needs

### 2. Metabolism Calculator (`services/ai/metabolism_calculator.py`)
- Calculates Basal Metabolic Rate (BMR) using Harris-Benedict & Mifflin-St Jeor equations
- Computes Total Daily Energy Expenditure (TDEE) based on activity level
- Adjusts calorie targets for weight goals (loss/gain/maintenance)

### 3. Nutrition Calculator (`services/ai/nutrition_calculator.py`)
- Calculates macro distribution (protein, carbs, fat)
- Computes micronutrient requirements
- Adjusts nutrition values for specific diet types

### 4. Meal Plan Generator (`services/ai/meal_plan_generator.py`)
- Generates daily/weekly meal plans using rule-based algorithms
- Optimizes for nutritional balance and variety
- Respects dietary restrictions and preferences

## Getting Started

### Prerequisites
- Python 3.11+
- Poetry (recommended) or pip

### Installation

```bash
cd backend

# Using Poetry
poetry install
poetry run uvicorn app.main:app --reload

# Using pip
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Running Tests
```bash
# Using Poetry
poetry run pytest

# Using pip
pytest
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| POST | `/api/v1/users/analyze` | Analyze user profile |
| POST | `/api/v1/nutrition/calculate` | Calculate nutrition needs |
| POST | `/api/v1/meal-plans/generate` | Generate meal plan |
| GET | `/api/v1/meal-plans/{plan_id}` | Get meal plan details |
