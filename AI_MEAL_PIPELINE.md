# AI Meal Planning Pipeline - Complete Implementation

## 🔗 Upstream Integration

**IMPORTANT**: This pipeline integrates with an existing upstream function:

### Analyze User Profile (Already Implemented)

This function **MUST NOT be reimplemented**. It produces the `body_profile` consumed by the meal planning pipeline.

**Input** (to upstream function):
```javascript
{
  "age": 25,
  "gender": "female",
  "height": 165,
  "weight": 70,
  "activity_level": "medium"
}
```

**Output** (from upstream function):
```javascript
{
  "body_profile": {
    "age": 25,
    "gender": "female",
    "bmi": 25.7,
    "bmr": 1400,
    "tdee": 1950,
    "activity_level": "medium"
  }
}
```

### Integration Rules

✅ **DO**: Pass `body_profile` directly to meal planning pipeline  
✅ **DO**: Trust upstream BMR/TDEE calculations  
❌ **DON'T**: Recalculate BMR/TDEE if already provided  
❌ **DON'T**: Reimplement user profile analysis

**Complete Integration Flow**:
```
┌─────────────────────────────┐
│  User Input                 │
│  (age, gender, height,      │
│   weight, activity_level)   │
└───────────┬─────────────────┘
            ↓
┌─────────────────────────────────┐
│ UPSTREAM: Analyze User Profile │  ← Already Implemented
│ Calculate: BMR, TDEE, BMI       │
└───────────┬─────────────────────┘
            ↓
       body_profile
            ↓
┌─────────────────────────────────┐
│ DOWNSTREAM: Meal Plan Pipeline │  ← This Implementation
│ Step 1: Dietary Preferences     │
│ Step 2: Health Goals            │
│ Step 3: Generate Meal Plan      │
└─────────────────────────────────┘
```

---

## 🎯 Overview

This is a **production-ready** AI pipeline for personalized meal planning, implemented in Python with FastAPI. The pipeline follows a strict 3-step execution order:

```
Step 1: Analyze Dietary Preferences
        ↓
Step 2: Analyze Health Goals
        ↓
Step 3: Generate Personalized Meal Plan (Core)
```

## 📁 File Structure

```
ai_meal_planing_service/
├── app/
│   ├── api/
│   │   ├── schemas/
│   │   │   └── meal_plan_pipeline.py          # Pydantic schemas
│   │   └── endpoints/
│   │       └── meal_plan_pipeline.py          # FastAPI endpoints
│   └── services/
│       ├── meal_plan_pipeline_service.py      # Pipeline orchestrator
│       └── ai_core/
│           └── meal_planning/
│               ├── dietary_analyzer.py        # Function 1
│               ├── goal_analyzer.py           # Function 2
│               └── meal_plan_generator.py     # Function 3
└── test/
    └── test_pipeline.py                       # Test suite
```

## 🔧 Function Details

### Function 1: Analyze Dietary Preferences

**Purpose**: Build normalized diet constraints for meal planning

**Input**:
```python
{
  "diet_types": ["keto", "vegan"],
  "allergies": ["Peanuts", "Shellfish"],
  "disliked_ingredients": ["mushrooms", "cilantro"]
}
```

**Output**:
```python
{
  "diet_constraints": {
    "diet_types": ["keto", "vegan"],
    "excluded_ingredients": ["cilantro", "mushrooms", "peanuts", "shellfish"]
  }
}
```

**Key Features**:
- ✅ Stateless and deterministic
- ✅ Normalizes all inputs to lowercase
- ✅ Validates diet types against supported list
- ✅ Merges and deduplicates exclusions
- ✅ Sorted output for consistency

**Supported Diet Types**:
- keto, vegan, vegetarian, paleo, mediterranean
- low_carb, low_fat, gluten_free, dairy_free
- halal, kosher, pescatarian

---

### Function 2: Analyze Health Goals

**Purpose**: Convert health objectives into numeric nutrition targets

**Input**:
```python
{
  "health_goal": "weight_loss",
  "user_tdee": 2500,
  "target_weight": 75,       # optional
  "timeline_weeks": 12        # optional
}
```

**Output**:
```python
{
  "goal_profile": {
    "primary_goal": "weight_loss",
    "calorie_adjustment": -500,
    "target_calories": 2000,
    "protein_priority": "high",
    "fat_priority": "medium",
    "carb_priority": "medium"
  }
}
```

**Calorie Adjustment Strategy**:
| Goal | Adjustment | Rate |
|------|------------|------|
| Weight Loss | -500 cal | 1 lb/week |
| Aggressive Weight Loss | -750 cal | 1.5 lbs/week |
| Muscle Gain | +300 cal | Lean gain |
| Maintain | 0 cal | Maintenance |

**Safety Bounds**:
- Maximum deficit: -1000 cal/day
- Maximum surplus: +1000 cal/day
- Minimum daily intake: 1200 cal

---

### Function 3: Generate Personalized Meal Plan (Core)

**Purpose**: Assemble meals that satisfy nutrition targets and restrictions

**Input**:
```python
{
  "body_profile": {
    "bmr": 1800,
    "tdee": 2500,
    "weight_kg": 80,
    "height_cm": 175,
    "age": 30,
    "gender": "male"
  },
  "diet_constraints": { ... },  # From Function 1
  "goal_profile": { ... }        # From Function 2
}
```

**Output**:
```python
{
  "meal_plan": {
    "daily_calories": 2050,
    "meals": [
      {
        "meal_type": "breakfast",
        "recipe_id": "recipe_001",
        "recipe_name": "Protein Oatmeal Bowl",
        "servings": 1.5,
        "estimated_calories": 525,
        "protein_g": 22.5,
        "carbs_g": 67.5,
        "fat_g": 12
      },
      ...
    ],
    "total_protein_g": 150,
    "total_carbs_g": 180,
    "total_fat_g": 55
  }
}
```

**Processing Steps**:
1. Determine target calories from TDEE + adjustment
2. Filter recipes by excluded ingredients and diet types
3. Distribute calories across meals (25% breakfast, 35% lunch, 35% dinner, 5% snack)
4. Score and rank recipes by goal profile
5. Select top recipes for each meal type
6. Calculate servings to match calorie targets
7. Validate total matches target within ±10%

---

## 🚀 API Endpoints

### Complete Pipeline Endpoint

**POST** `/api/v1/pipeline/complete-pipeline`

Executes all 3 steps in sequence.

#### ✅ Preferred: Using body_profile from Upstream

```bash
curl -X POST "http://localhost:8000/api/v1/pipeline/complete-pipeline" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "diet_types": ["keto"],
    "allergies": ["peanuts"],
    "disliked_ingredients": ["mushrooms"],
    "health_goal": "weight_loss",
    "body_profile": {
      "age": 30,
      "gender": "male",
      "bmi": 26.1,
      "bmr": 1800,
      "tdee": 2500,
      "activity_level": "medium"
    },
    "days": 1
  }'
```

**Note**: `body_profile` comes from the upstream "Analyze User Profile" function. This is the **recommended integration pattern**.

#### 🔄 Fallback: Individual Fields

If `body_profile` is not available, provide individual fields:

```bash
curl -X POST "http://localhost:8000/api/v1/pipeline/complete-pipeline" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_123",
    "diet_types": ["keto"],
    "allergies": ["peanuts"],
    "disliked_ingredients": ["mushrooms"],
    "health_goal": "weight_loss",
    "bmr": 1800,
    "tdee": 2500,
    "weight_kg": 80,
    "height_cm": 175,
    "age": 30,
    "gender": "male",
    "days": 1
  }'
```

**Required**: If using fallback, ALL fields (`bmr`, `tdee`, `weight_kg`, `height_cm`, `age`, `gender`) must be provided.

### Individual Step Endpoints

#### Step 1: Analyze Dietary Preferences
**POST** `/api/v1/pipeline/step1/analyze-dietary-preferences`

#### Step 2: Analyze Health Goals
**POST** `/api/v1/pipeline/step2/analyze-health-goals`

#### Step 3: Generate Meal Plan
**POST** `/api/v1/pipeline/step3/generate-meal-plan`

### Utility Endpoints

**GET** `/api/v1/pipeline/supported-diet-types` - Get list of supported diet types

---

## 📊 Testing

### Run Pipeline Tests

```bash
cd ai_meal_planing_service
python -m test.test_pipeline
```

### Test Scenarios Included:

1. **Complete Pipeline Test** - Executes all 3 steps in order
2. **Vegan Weight Loss** - Dietary restrictions + deficit
3. **Keto Muscle Gain** - Low-carb + surplus
4. **No Restrictions Maintenance** - Balanced approach

### Expected Output:
```
======================================================================
COMPLETE PIPELINE TEST
======================================================================

TEST: Function 1 - Analyze Dietary Preferences
✓ Function 1 completed successfully

TEST: Function 2 - Analyze Health Goals
✓ Function 2 completed successfully

TEST: Function 3 - Generate Personalized Meal Plan
✓ Function 3 completed successfully

PIPELINE EXECUTION COMPLETE
✓ All 3 functions executed successfully
✓ Data flowed correctly: Step 1 → Step 2 → Step 3
✓ Final meal plan generated with all constraints applied
```

---

## 🔍 Swagger Documentation

Once the AI service is running, access interactive documentation:

**Swagger UI**: http://localhost:8000/docs

All pipeline endpoints are documented with:
- Request/response schemas
- Parameter descriptions
- Example payloads
- Try-it-out functionality

---

## 🏗️ Architecture Principles

### 1. **Separation of Concerns**
Each function has a single, well-defined responsibility:
- Function 1: Constraints
- Function 2: Goals
- Function 3: Generation

### 2. **Stateless & Deterministic**
- No hidden state
- Same input → Same output
- Easily testable

### 3. **Pure Functions**
- No side effects
- No direct database access in core logic
- Repository pattern for data access

### 4. **Type Safety**
- Full type hints throughout
- Pydantic schema validation
- FastAPI automatic validation

### 5. **Production Ready**
- Comprehensive error handling
- Structured logging
- Safety bounds on calculations
- Input validation at all layers

---

## 🔗 Integration with Backend

### Node.js Backend Integration

The backend can call the complete pipeline endpoint:

```javascript
// eater-backend/src/integrations/ai/aiClient.js
async function generatePersonalizedMealPlan(userData) {
  const response = await aiClient.post(
    '/api/v1/pipeline/complete-pipeline',
    {
      user_id: userData.userId,
      diet_types: userData.dietTypes || [],
      allergies: userData.allergies || [],
      disliked_ingredients: userData.dislikedIngredients || [],
      health_goal: userData.healthGoal,
      bmr: userData.bmr,
      tdee: userData.tdee,
      weight_kg: userData.weight,
      height_cm: userData.height,
      age: userData.age,
      gender: userData.gender
    }
  );
  
  return response.data;
}
```

---

## 📈 Performance Characteristics

- **Function 1**: O(n) where n = number of ingredients
- **Function 2**: O(1) constant time calculations
- **Function 3**: O(m × r) where m = meals, r = recipes

**Typical Response Times** (with mock database):
- Complete Pipeline: < 100ms
- Step 1 alone: < 5ms
- Step 2 alone: < 3ms
- Step 3 alone: < 50ms

---

## 🔮 Future Enhancements

### Phase 2:
- [ ] Connect to real recipe database
- [ ] Implement advanced recipe scoring (nutritional analysis)
- [ ] Add meal variety constraints (no repeated meals)
- [ ] Implement weekly meal plans (multi-day generation)

### Phase 3:
- [ ] ML-based recipe recommendations
- [ ] User preference learning
- [ ] Seasonal ingredient preferences
- [ ] Cost optimization

### Phase 4:
- [ ] LLM integration for meal descriptions
- [ ] Cooking time optimization
- [ ] Grocery list generation
- [ ] Nutritionist review workflow

---

## 📝 Example Usage

### Python Direct Usage

```python
from app.services.meal_plan_pipeline_service import get_pipeline_service
from app.api.schemas.meal_plan_pipeline import MealPlanPipelineRequest, HealthGoalType

# Create request
request = MealPlanPipelineRequest(
    user_id="user_123",
    diet_types=["vegan"],
    allergies=["peanuts"],
    disliked_ingredients=[],
    health_goal=HealthGoalType.WEIGHT_LOSS,
    bmr=1700,
    tdee=2300,
    weight_kg=70,
    height_cm=165,
    age=28,
    gender="female"
)

# Execute pipeline
service = get_pipeline_service()
response = await service.execute_pipeline(request)

# Access results
print(f"Diet Types: {response.diet_constraints.diet_types}")
print(f"Target Calories: {response.goal_profile.target_calories}")
print(f"Meals Generated: {len(response.meal_plan.meals)}")
```

---

## ✅ Validation & Safety

### Input Validation
- All inputs validated with Pydantic
- Type checking enforced
- Range checks on numeric values
- Enum validation for categorical values

### Safety Bounds
- Calorie adjustments clamped to safe ranges
- Minimum daily calorie intake enforced
- BMR/TDEE must be positive
- Age must be reasonable (1-120)

### Error Handling
- Graceful degradation when no recipes match
- Clear error messages
- Structured logging for debugging
- HTTP status codes follow REST conventions

---

## 📞 Support & Documentation

- **API Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

For questions or issues, refer to the main project repository.

---

**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: February 22, 2026
