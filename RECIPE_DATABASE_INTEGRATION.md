# Recipe Database Integration Guide

## 🎯 Overview

This guide explains how to integrate **real MongoDB recipes** with the **AI Meal Plan Generator**.

## 📊 Architecture Flow

```
┌─────────────────────────┐
│  MongoDB Database       │
│  - Recipes             │
│  - RecipeNutrition     │
│  - RecipeDietTypes     │
│  - RecipesIngredients  │
└──────────┬──────────────┘
           ↓
┌─────────────────────────┐
│  Recipe Service         │
│  getRecipesForAI()      │
│  - Fetch from DB        │
│  - Join related data    │
│  - Format for AI        │
└──────────┬──────────────┘
           ↓
┌─────────────────────────┐
│  AI Client              │
│  generateMealPlanPipeline()
│  - Pass recipe_database │
└──────────┬──────────────┘
           ↓
┌─────────────────────────┐
│  AI Service (Python)    │
│  /api/pipeline/...      │
│  - Filter by constraints│
│  - Score recipes        │
│  - Generate meal plan   │
└─────────────────────────┘
```

## 🔧 Step-by-Step Integration

### Step 1: Fetch Recipes from MongoDB

Use the **Recipe Service** to fetch and format recipes:

```javascript
const recipeService = require("./src/api/services/recipe.service");

// Fetch all published recipes
const recipes = await recipeService.getRecipesForAI();

// Or fetch with filters
const filteredRecipes = await recipeService.getRecipesForAI({
  dietTypes: ["vegetarian", "vegan"],
  excludeIngredients: ["peanuts", "shellfish"]
});
```

**Recipe Format** (what the AI expects):
```javascript
{
  id: "recipe_mongo_id",
  name: "Grilled Chicken Salad",
  description: "Healthy protein-rich salad",
  image_url: "https://...",
  cooking_time: 25,
  base_servings: 2,
  
  // Nutrition (per serving)
  calories_per_serving: 400,
  protein_g: 35,
  carbs_g: 20,
  fat_g: 18,
  
  // Diet types (lowercase, underscore format)
  diet_types: ["low_carb", "paleo"],
  
  // Ingredients (for exclusion filtering)
  ingredients: ["chicken breast", "lettuce", "tomato"],
  
  // Metadata
  rating: 4.5,
  review_count: 120
}
```

### Step 2: Analyze User Profile

Get the user's metabolic data:

```javascript
const aiClient = require("./src/integrations/ai/aiClient");

const profileResponse = await aiClient.analyzeUserProfile({
  user_id: "user_123",
  age: 30,
  gender: "female",
  height_cm: 165,
  weight_kg: 70,
  goal_weight_kg: 65,
  health_goals: "weight_loss",
  activity_level: "moderate"  // Valid values: sedentary, light, moderate, active, very_active
});

const body_profile = {
  age: profileResponse.age,
  gender: profileResponse.gender,
  bmi: profileResponse.bmi,
  bmr: profileResponse.health_metrics.bmr,
  tdee: profileResponse.health_metrics.tdee,
  activity_level: profileResponse.activity_level
};
```

### Step 3: Generate Meal Plan with Real Recipes

Pass the recipe database to the AI pipeline:

```javascript
const mealPlan = await aiClient.generateMealPlanPipeline({
  user_id: "user_123",
  
  // Diet preferences
  diet_types: ["vegetarian"],
  allergies: ["peanuts"],
  disliked_ingredients: ["mushrooms"],
  
  // Health goals
  health_goal: "weight_loss",
  target_weight: 65,
  timeline_weeks: 12,
  
  // Body profile from Step 2
  body_profile: body_profile,
  
  // Real recipes from MongoDB! ✨
  recipe_database: recipes,
  
  // Generation settings
  days: 1
});
```

### Step 4: Use Generated Meal Plan

The response includes:

```javascript
{
  user_id: "user_123",
  
  // Step 1 output
  diet_constraints: {
    diet_types: ["vegetarian"],
    excluded_ingredients: ["mushrooms", "peanuts"]
  },
  
  // Step 2 output
  goal_profile: {
    primary_goal: "weight_loss",
    target_calories: 1800,
    calorie_adjustment: -500,
    protein_priority: "high",
    fat_priority: "medium",
    carb_priority: "medium"
  },
  
  // Step 3 output - Real recipes from MongoDB!
  meal_plan: {
    daily_calories: 1820,
    meals: [
      {
        meal_type: "breakfast",
        recipe_id: "64f3a2b1c9e8f1234567890a", // ← MongoDB _id
        recipe_name: "Protein Oatmeal Bowl",
        servings: 1.5,
        estimated_calories: 450,
        protein_g: 22,
        carbs_g: 58,
        fat_g: 12
      },
      // ... more meals
    ],
    total_protein_g: 95,
    total_carbs_g: 180,
    total_fat_g: 55
  }
}
```

## 🗄️ Database Schema Requirements

### Required Models

1. **Recipe** - Basic recipe info
   - `name`, `description`, `imageUrl`
   - `cookingTime`, `baseServings`
   - `status` (must be "published")

2. **RecipeNutrition** - Nutrition data
   - `recipeId` (ref to Recipe)
   - `calories`, `protein`, `fat`, `carbohydrates`

3. **RecipeDietType** - Diet type associations
   - `recipeId` (ref to Recipe)
   - `dietTypeId` (ref to DietType)

4. **RecipesIngredient** - Ingredient associations
   - `recipeId` (ref to Recipe)
   - `ingredientId` (ref to Ingredient)
   - `base_quantity`, `unit`

5. **Ingredient** - Individual ingredients
   - `name`, `unit`
   - `calories_per_unit`, `protein`, `carbs`, `fats`

6. **DietType** - Diet type definitions
   - `name` (e.g., "Vegetarian", "Keto")
   - `carb_ratio`, `protein_ratio`, `fat_ratio`

### Supported Diet Types

The AI expects these diet type names (lowercase, underscores):
- `vegetarian`
- `vegan`
- `keto`
- `paleo`
- `mediterranean`
- `low_carb`
- `low_fat`
- `gluten_free`
- `dairy_free`
- `pescatarian`
- `halal`
- `kosher`

**Note**: The Recipe Service automatically converts your database diet type names to this format.

## 🔍 How the AI Uses Recipes

### 1. Filtering Phase
```python
# AI filters recipes by:
- Diet types (must match user's diet_types)
- Excluded ingredients (removes recipes with allergies/dislikes)
```

### 2. Scoring Phase
```python
# AI scores each recipe based on:
- Recipe rating (from reviews)
- Popularity (review count)
- Macro matching (protein/carb/fat priorities)
- Meal type appropriateness
```

### 3. Selection Phase
```python
# AI selects recipes to:
- Match target calories (±10%)
- Distribute across meal types (breakfast, lunch, dinner, snack)
- Balance macros according to health goal
```

### 4. Adjustment Phase
```python
# AI adjusts serving sizes to:
- Hit exact calorie targets per meal
- Calculate precise macro amounts
```

## 📝 Complete Example

See **example-recipe-integration.js** for a complete working example:

```bash
cd eater-backend
node example-recipe-integration.js
```

This example demonstrates:
- ✅ Fetching recipes from MongoDB
- ✅ Analyzing user profile
- ✅ Generating meal plan with real recipes
- ✅ Pre-filtering recipes by diet type
- ✅ Checking recipe availability

## 🚀 Production Usage

### In your meal planning service/controller:

```javascript
async function generateUserMealPlan(userId, preferences) {
  // 1. Get user profile data
  const user = await User.findById(userId);
  
  // 2. Analyze profile
  const profileData = {
    user_id: userId,
    age: user.age,
    gender: user.gender,
    height_cm: user.profile.height,
    weight_kg: user.profile.weight,
    goal_weight_kg: user.profile.goalWeight || user.profile.weight,
    health_goals: preferences.healthGoal || "maintain",
    activity_level: user.profile.activityLevel
  };
  const analysis = await aiClient.analyzeUserProfile(profileData);
  
  // 3. Fetch available recipes
  const recipes = await recipeService.getRecipesForAI({
    dietTypes: preferences.dietTypes,
    excludeIngredients: [...preferences.allergies, ...preferences.dislikes]
  });
  
  // 4. Generate meal plan
  const mealPlan = await aiClient.generateMealPlanPipeline({
    user_id: userId,
    diet_types: preferences.dietTypes,
    allergies: preferences.allergies,
    disliked_ingredients: preferences.dislikes,
    health_goal: preferences.healthGoal,
    body_profile: {
      age: analysis.age,
      gender: analysis.gender,
      bmi: analysis.bmi,
      bmr: analysis.health_metrics.bmr,
      tdee: analysis.health_metrics.tdee,
      activity_level: analysis.activity_level
    },
    recipe_database: recipes,
    days: preferences.days || 1
  });
  
  // 5. Save to database
  await saveMealPlanToDatabase(userId, mealPlan);
  
  return mealPlan;
}
```

## ⚠️ Important Notes

1. **Recipe Status**: Only recipes with `status: "published"` are fetched
2. **Nutrition Data**: Recipes without nutrition data will use default values
3. **Diet Types**: Ensure your diet types match the supported format
4. **Ingredients**: Include all ingredients for proper allergy filtering
5. **Performance**: The service fetches all data in parallel for efficiency

## 🐛 Troubleshooting

### No recipes in meal plan?
- Check if you have published recipes in MongoDB
- Verify recipe nutrition data exists
- Check if diet type filters are too restrictive

### Wrong nutrition values?
- Ensure RecipeNutrition data is per recipe (not per serving)
- Recipe Service calculates per-serving values automatically

### Recipes not matching diet type?
- Check RecipeDietType associations
- Verify DietType names match supported formats

## 📚 Related Files

- **Recipe Service**: `eater-backend/src/api/services/recipe.service.js`
- **AI Client**: `eater-backend/src/integrations/ai/aiClient.js`
- **Models**:
  - `eater-backend/src/models/Recipe.js`
  - `eater-backend/src/models/recipe_nutrion.js`
  - `eater-backend/src/models/recipe_diet_type.js`
  - `eater-backend/src/models/recipes_ingredient.js`
- **AI Generator**: `ai_meal_planing_service/app/services/ai_core/meal_planning/meal_plan_generator.py`

---

**Happy Meal Planning! 🍽️✨**
