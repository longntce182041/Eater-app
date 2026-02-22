# Postman Testing Guide - AI Meal Planning Pipeline

## 🔧 Setup

**Base URL**: `http://localhost:8000`

Make sure the AI service is running:
```bash
cd ai_meal_planing_service
python -m uvicorn app.main:app --reload --port 8000
```

---

## 📍 Endpoint 1: Complete Pipeline (All 3 Steps)

**Method**: `POST`  
**URL**: `http://localhost:8000/api/pipeline/complete-pipeline`

**Headers**:
```
Content-Type: application/json
```

### ✅ **Preferred Method: Using body_profile from Upstream**

This is the **recommended approach** when integrating with the existing "Analyze User Profile" function:

**Body** (raw JSON):
```json
{
  "user_id": "user_12345",
  "diet_types": ["keto", "gluten_free"],
  "allergies": ["peanuts", "shellfish"],
  "disliked_ingredients": ["mushrooms", "cilantro"],
  "health_goal": "weight_loss",
  "target_weight": 70,
  "timeline_weeks": 12,
  "body_profile": {
    "age": 30,
    "gender": "male",
    "bmi": 26.1,
    "bmr": 1800,
    "tdee": 2500,
    "activity_level": "medium"
  },
  "days": 1
}
```

**Key Points**:
- `body_profile` comes from the upstream **"Analyze User Profile"** function
- BMR/TDEE are already calculated - no recalculation needed
- This is the proper integration pattern
- Trust the upstream metabolic calculations

---

### 🔄 **Alternative Method: Fallback with Individual Fields**

Use this only when body_profile is not available:

**Body** (raw JSON):
```json
{
  "user_id": "user_12345",
  "diet_types": ["keto", "gluten_free"],
  "allergies": ["peanuts", "shellfish"],
  "disliked_ingredients": ["mushrooms", "cilantro"],
  "health_goal": "weight_loss",
  "target_weight": 70,
  "timeline_weeks": 12,
  "bmr": 1800,
  "tdee": 2500,
  "weight_kg": 80,
  "height_cm": 175,
  "age": 30,
  "gender": "male",
  "days": 1
}
```

**Note**: If you provide individual fields, ALL of these are required: `bmr`, `tdee`, `weight_kg`, `height_cm`, `age`, `gender`

---

**Expected Response** (200 OK):
```json
{
  "user_id": "user_12345",
  "diet_constraints": {
    "diet_types": ["gluten_free", "keto"],
    "excluded_ingredients": ["cilantro", "mushrooms", "peanuts", "shellfish"]
  },
  "goal_profile": {
    "primary_goal": "weight_loss",
    "calorie_adjustment": -500,
    "target_calories": 2000,
    "protein_priority": "high",
    "fat_priority": "medium",
    "carb_priority": "medium"
  },
  "meal_plan": {
    "daily_calories": 2050,
    "meals": [
      {
        "meal_type": "breakfast",
        "recipe_id": "recipe_003",
        "recipe_name": "Salmon with Vegetables",
        "servings": 1.39,
        "estimated_calories": 625,
        "protein_g": 55.6,
        "carbs_g": 20.85,
        "fat_g": 34.75
      },
      // ... more meals
    ],
    "total_protein_g": 155.2,
    "total_carbs_g": 95.25,
    "total_fat_g": 89.25
  },
  "pipeline_metadata": {
    "user_id": "user_12345",
    "pipeline_version": "1.0.0",
    "steps_executed": 3,
    "generation_metadata": {
      "target_calories": 2000,
      "calorie_match_percentage": 102.5,
      "candidate_recipes_count": 2,
      "meals_generated": 4
    }
  }
}
```

---

## 📍 Endpoint 2: Step 1 - Analyze Dietary Preferences

**Method**: `POST`  
**URL**: `http://localhost:8000/api/pipeline/step1/analyze-dietary-preferences`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "diet_types": ["vegan", "gluten_free"],
  "allergies": ["Peanuts", "Tree Nuts", "Shellfish"],
  "disliked_ingredients": ["Brussels Sprouts", "MUSHROOMS", "cilantro"]
}
```

**Expected Response** (200 OK):
```json
{
  "diet_constraints": {
    "diet_types": ["gluten_free", "vegan"],
    "excluded_ingredients": [
      "brussels sprouts",
      "cilantro",
      "mushrooms",
      "peanuts",
      "shellfish",
      "tree nuts"
    ]
  }
}
```

---

## 📍 Endpoint 3: Step 2 - Analyze Health Goals

**Method**: `POST`  
**URL**: `http://localhost:8000/api/pipeline/step2/analyze-health-goals`

**Headers**:
```
Content-Type: application/json
```

**Body Option 1** (Weight Loss):
```json
{
  "health_goal": "weight_loss",
  "user_tdee": 2500,
  "target_weight": 70,
  "timeline_weeks": 12
}
```

**Body Option 2** (Muscle Gain):
```json
{
  "health_goal": "muscle_gain",
  "user_tdee": 2800,
  "target_weight": 85,
  "timeline_weeks": 16
}
```

**Body Option 3** (Maintenance):
```json
{
  "health_goal": "maintain",
  "user_tdee": 2300
}
```

**Body Option 4** (Aggressive Weight Loss):
```json
{
  "health_goal": "aggressive_weight_loss",
  "user_tdee": 2200
}
```

**Expected Response** (200 OK):
```json
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

---

## 📍 Endpoint 4: Step 3 - Generate Meal Plan

**Method**: `POST`  
**URL**: `http://localhost:8000/api/pipeline/step3/generate-meal-plan`

**Headers**:
```
Content-Type: application/json
```

**Body** (raw JSON):
```json
{
  "body_profile": {
    "bmr": 1700,
    "tdee": 2300,
    "weight_kg": 70,
    "height_cm": 165,
    "age": 28,
    "gender": "female"
  },
  "diet_constraints": {
    "diet_types": ["vegetarian"],
    "excluded_ingredients": ["peanuts", "shellfish"]
  },
  "goal_profile": {
    "primary_goal": "weight_loss",
    "calorie_adjustment": -500,
    "target_calories": 1800,
    "protein_priority": "high",
    "fat_priority": "medium",
    "carb_priority": "medium"
  },
  "days": 1
}
```

**Expected Response** (200 OK):
```json
{
  "meal_plan": {
    "daily_calories": 1780,
    "meals": [
      {
        "meal_type": "breakfast",
        "recipe_id": "recipe_001",
        "recipe_name": "Protein Oatmeal Bowl",
        "servings": 1.29,
        "estimated_calories": 450,
        "protein_g": 19.35,
        "carbs_g": 58.05,
        "fat_g": 10.32
      },
      {
        "meal_type": "lunch",
        "recipe_id": "recipe_004",
        "recipe_name": "Vegan Buddha Bowl",
        "servings": 1.66,
        "estimated_calories": 630,
        "protein_g": 19.92,
        "carbs_g": 91.3,
        "fat_g": 16.6
      },
      {
        "meal_type": "dinner",
        "recipe_id": "recipe_001",
        "recipe_name": "Protein Oatmeal Bowl",
        "servings": 1.8,
        "estimated_calories": 630,
        "protein_g": 27,
        "carbs_g": 81,
        "fat_g": 14.4
      },
      {
        "meal_type": "snack",
        "recipe_id": "recipe_005",
        "recipe_name": "Greek Yogurt Parfait",
        "servings": 0.36,
        "estimated_calories": 90,
        "protein_g": 6.48,
        "carbs_g": 10.8,
        "fat_g": 1.8
      }
    ],
    "total_protein_g": 72.75,
    "total_carbs_g": 241.15,
    "total_fat_g": 43.12
  },
  "metadata": {
    "target_calories": 1800,
    "calorie_match_percentage": 98.89,
    "candidate_recipes_count": 4,
    "meals_generated": 4
  }
}
```

---

## 📍 Endpoint 5: Get Supported Diet Types

**Method**: `GET`  
**URL**: `http://localhost:8000/api/pipeline/supported-diet-types`

**No body required**

**Expected Response** (200 OK):
```json
{
  "supported_diet_types": [
    "dairy_free",
    "gluten_free",
    "halal",
    "kosher",
    "keto",
    "low_carb",
    "low_fat",
    "mediterranean",
    "paleo",
    "pescatarian",
    "vegan",
    "vegetarian"
  ],
  "count": 12
}
```

---

## 🧪 Test Scenarios

### 🔗 **INTEGRATION FLOW: Backend → Analyze User Profile → Meal Planning Pipeline**

This demonstrates the complete integration pattern:

**Step 1**: Call `/api/ai/user-profile/analyze` (existing function)
**Step 2**: Extract `body_profile` from response
**Step 3**: Pass `body_profile` to `/api/v1/pipeline/complete-pipeline`

#### Full Integration Example

**1️⃣ First: Analyze User Profile**
```javascript
// Backend endpoint (already implemented)
POST http://localhost:3000/api/ai/user-profile/analyze

{
  "userId": "user_12345",
  "age": 30,
  "gender": "male",
  "height": 175,
  "weight": 80,
  "activityLevel": "medium"
}

// Response:
{
  "body_profile": {
    "age": 30,
    "gender": "male",
    "bmi": 26.1,
    "bmr": 1800,
    "tdee": 2500,
    "activity_level": "medium"
  }
}
```

**2️⃣ Then: Generate Meal Plan (using body_profile)**
```javascript
// AI service endpoint (new pipeline)
POST http://localhost:8000/api/pipeline/complete-pipeline

{
  "user_id": "user_12345",
  "diet_types": ["keto"],
  "allergies": ["peanuts"],
  "disliked_ingredients": [],
  "health_goal": "weight_loss",
  "body_profile": {  // ← From Step 1
    "age": 30,
    "gender": "male",
    "bmi": 26.1,
    "bmr": 1800,
    "tdee": 2500,
    "activity_level": "medium"
  },
  "days": 1
}
```

**Key Benefits**:
- ✅ No duplicate calculations (BMR/TDEE calculated once)
- ✅ Consistent metabolic data across services
- ✅ Clean separation of concerns
- ✅ Proper upstream/downstream integration

---

## 🧪 Standalone Test Scenarios

### Scenario 1: Vegan Weight Loss
```json
{
  "user_id": "vegan_user",
  "diet_types": ["vegan"],
  "allergies": ["soy"],
  "disliked_ingredients": ["tofu"],
  "health_goal": "weight_loss",
  "bmr": 1600,
  "tdee": 2200,
  "weight_kg": 75,
  "height_cm": 170,
  "age": 32,
  "gender": "female"
}
```

### Scenario 2: Keto Muscle Gain
```json
{
  "user_id": "keto_athlete",
  "diet_types": ["keto", "low_carb"],
  "allergies": [],
  "disliked_ingredients": [],
  "health_goal": "muscle_gain",
  "bmr": 1900,
  "tdee": 2800,
  "weight_kg": 85,
  "height_cm": 180,
  "age": 25,
  "gender": "male"
}
```

### Scenario 3: Gluten-Free Maintenance
```json
{
  "user_id": "gluten_free_user",
  "diet_types": ["gluten_free"],
  "allergies": ["wheat", "barley"],
  "disliked_ingredients": ["brussels sprouts"],
  "health_goal": "maintain",
  "bmr": 1750,
  "tdee": 2400,
  "weight_kg": 78,
  "height_cm": 175,
  "age": 35,
  "gender": "male"
}
```

### Scenario 4: Pescatarian Weight Loss
```json
{
  "user_id": "pescatarian_user",
  "diet_types": ["pescatarian", "mediterranean"],
  "allergies": ["shellfish"],
  "disliked_ingredients": ["cilantro", "anchovy"],
  "health_goal": "weight_loss",
  "bmr": 1550,
  "tdee": 2100,
  "weight_kg": 68,
  "height_cm": 163,
  "age": 29,
  "gender": "female"
}
```

---

## 🔍 Validation Test Cases

### Test Invalid Health Goal
```json
{
  "user_id": "test_user",
  "diet_types": [],
  "allergies": [],
  "disliked_ingredients": [],
  "health_goal": "invalid_goal",  // Should fail
  "bmr": 1800,
  "tdee": 2500,
  "weight_kg": 80,
  "height_cm": 175,
  "age": 30,
  "gender": "male"
}
```
**Expected**: 422 Unprocessable Entity

### Test Negative BMR
```json
{
  "user_id": "test_user",
  "diet_types": [],
  "allergies": [],
  "disliked_ingredients": [],
  "health_goal": "maintain",
  "bmr": -1800,  // Should fail
  "tdee": 2500,
  "weight_kg": 80,
  "height_cm": 175,
  "age": 30,
  "gender": "male"
}
```
**Expected**: 400 Bad Request

### Test Invalid Age
```json
{
  "user_id": "test_user",
  "diet_types": [],
  "allergies": [],
  "disliked_ingredients": [],
  "health_goal": "maintain",
  "bmr": 1800,
  "tdee": 2500,
  "weight_kg": 80,
  "height_cm": 175,
  "age": 150,  // Should fail
  "gender": "male"
}
```
**Expected**: 400 Bad Request

---

## 📊 Health Goal Options

Valid values for `health_goal`:
- `"weight_loss"` - Standard weight loss (500 cal deficit)
- `"aggressive_weight_loss"` - Faster weight loss (750 cal deficit)
- `"muscle_gain"` - Lean muscle gain (300 cal surplus)
- `"maintain"` - Weight maintenance (no adjustment)

---

## 👥 Gender Options

Valid values for `gender`:
- `"male"`
- `"female"`
- `"other"`

---

## 🎯 Quick Test Steps in Postman

1. **Create New Request**
   - Click "New" → "HTTP Request"

2. **Set Method and URL**
   - Method: `POST`
   - URL: `http://localhost:8000/api/v1/pipeline/complete-pipeline`

3. **Set Headers**
   - Key: `Content-Type`
   - Value: `application/json`

4. **Set Body**
   - Select "Body" tab
   - Select "raw"
   - Select "JSON" from dropdown
   - Paste the JSON example above

5. **Send Request**
   - Click "Send"
   - Check response in lower panel

6. **Save Request** (Optional)
   - Click "Save" to add to a collection
   - Name it "Complete Pipeline Test"

---

## 🐛 Troubleshooting

### Error: Connection Refused
- **Cause**: AI service not running
- **Solution**: Start the service with `python -m uvicorn app.main:app --reload --port 8000`

### Error: 422 Unprocessable Entity
- **Cause**: Invalid JSON format or missing required fields
- **Solution**: Check JSON syntax and ensure all required fields are present

### Error: 400 Bad Request
- **Cause**: Validation failed (negative values, invalid ranges)
- **Solution**: Check the error message in response, fix the invalid values

### Empty Meal Plan
- **Cause**: No recipes match the diet constraints
- **Solution**: Try less restrictive diet types or fewer exclusions

---

## 📝 Collection Import (Optional)

You can also access the Swagger UI for interactive testing:

**URL**: http://localhost:8000/docs

Registered endpoints:
- `/api/pipeline/complete-pipeline`
- `/api/pipeline/step1/analyze-dietary-preferences`
- `/api/pipeline/step2/analyze-health-goals`
- `/api/pipeline/step3/generate-meal-plan`
- `/api/pipeline/supported-diet-types`

The Swagger UI provides:
- Interactive API documentation
- Built-in "Try it out" functionality
- Automatic request/response examples
- Schema documentation

---

## ✅ Expected Results Checklist

After testing the complete pipeline, verify:

- ✅ Diet types are normalized and validated
- ✅ Excluded ingredients are merged and deduplicated
- ✅ Calorie adjustment matches health goal
- ✅ Target calories = TDEE + adjustment
- ✅ Macro priorities align with goal
- ✅ Meal plan respects diet constraints
- ✅ Total calories within ±10% of target
- ✅ All meals have recipe details
- ✅ Metadata includes generation statistics

---

**Happy Testing! 🚀**
