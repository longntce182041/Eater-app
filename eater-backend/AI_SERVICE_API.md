# AI Service API Documentation

## Overview

The AI Service provides endpoints for generating personalized meal plans, getting recommendations, and integrating with the AI meal planning service.

## Base URL

```
http://localhost:3000/api/ai
```

## Endpoints

### 1. Generate Meal Plan

Generate an AI-powered meal plan for a user based on their profile, dietary preferences, and health metrics.

**Endpoint:** `POST /api/ai/meal-plan/generate`

**Request Body:**

```json
{
  "userId": "507f1f77bcf86cd799439011",
  "days": 7,
  "useML": false
}
```

**Parameters:**

- `userId` (string, optional): MongoDB ObjectId of the user. If not provided, uses authenticated user's ID
- `days` (number, optional): Number of days for the meal plan (1-30). Default: 7
- `useML` (boolean, optional): Whether to use ML/LLM features. Default: false

**Response:**

```json
{
  "success": true,
  "message": "Meal plan generated and saved successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439012",
    "userId": "507f1f77bcf86cd799439011",
    "date": "2026-02-20T10:30:00.000Z",
    "days": 7,
    "createdAt": "2026-02-20T10:30:00.000Z",
    "updatedAt": "2026-02-20T10:30:00.000Z"
  }
}
```

**Example cURL:**

```bash
curl -X POST http://localhost:3000/api/ai/meal-plan/generate \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "507f1f77bcf86cd799439011",
    "days": 7,
    "useML": false
  }'
```

---

### 2. Get User Meal Plans

Retrieve all meal plans for a specific user.

**Endpoint:** `GET /api/ai/meal-plans`

**Query Parameters:**

- `userId` (string, optional): User ID. If not provided, uses authenticated user's ID
- `limit` (number, optional): Number of plans to retrieve (1-100). Default: 10

**Response:**

```json
{
  "success": true,
  "count": 3,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "userId": "507f1f77bcf86cd799439011",
      "date": "2026-02-20T10:30:00.000Z",
      "days": 7,
      "createdAt": "2026-02-20T10:30:00.000Z"
    }
  ]
}
```

**Example cURL:**

```bash
curl -X GET "http://localhost:3000/api/ai/meal-plans?userId=507f1f77bcf86cd799439011&limit=10"
```

---

### 3. Get Recommended Recipes

Get personalized recipe recommendations based on user preferences.

**Endpoint:** `GET /api/ai/recipes/recommended`

**Query Parameters:**

- `userId` (string, optional): User ID
- `limit` (number, optional): Number of recipes (1-100). Default: 10

**Response:**

```json
{
  "success": true,
  "count": 10,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439013",
      "name": "Grilled Chicken Salad",
      "description": "Healthy protein-rich salad",
      "dietTypeId": "507f1f77bcf86cd799439014",
      "rating": 4.5
    }
  ]
}
```

**Example cURL:**

```bash
curl -X GET "http://localhost:3000/api/ai/recipes/recommended?userId=507f1f77bcf86cd799439011&limit=10"
```

---

### 4. Get User Data for AI

Retrieve formatted user data prepared for AI service processing.

**Endpoint:** `GET /api/ai/user-data`

**Query Parameters:**

- `userId` (string, optional): User ID

**Response:**

```json
{
  "success": true,
  "data": {
    "userId": "507f1f77bcf86cd799439011",
    "profile": {
      "age": 30,
      "gender": "male",
      "height": 175,
      "weight": 75,
      "goalWeight": 70,
      "healthGoals": "weight loss"
    },
    "dietaryPreferences": {
      "dietTypeId": "507f1f77bcf86cd799439014",
      "allergens": ["peanuts"],
      "restrictions": ["gluten-free"],
      "excludedIngredients": []
    },
    "healthMetrics": {
      "bmi": 24.5,
      "bmr": 1680,
      "tdee": 2310
    }
  }
}
```

**Example cURL:**

```bash
curl -X GET "http://localhost:3000/api/ai/user-data?userId=507f1f77bcf86cd799439011"
```

---

### 5. Check AI Service Health

Check if the AI service is available and responding.

**Endpoint:** `GET /api/ai/health`

**Response:**

```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2026-02-20T10:30:00.000Z"
  }
}
```

**Example cURL:**

```bash
curl -X GET http://localhost:3000/api/ai/health
```

---

### 6. Get AI Service Status

Get detailed status information about the AI service.

**Endpoint:** `GET /api/ai/status`

**Response:**

```json
{
  "success": true,
  "data": {
    "available": true,
    "version": "1.0.0",
    "capabilities": ["meal_planning", "recipe_recommendation"]
  }
}
```

**Example cURL:**

```bash
curl -X GET http://localhost:3000/api/ai/status
```

---

## Error Responses

All endpoints return errors in the following format:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

### Common Error Codes:

- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (authentication required)
- `404` - Not Found (resource doesn't exist)
- `500` - Internal Server Error
- `503` - Service Unavailable (AI service is down)

---

## Usage Examples

### JavaScript/Node.js

```javascript
const axios = require("axios");

// Generate meal plan
async function generateMealPlan(userId, days = 7) {
  try {
    const response = await axios.post(
      "http://localhost:3000/api/ai/meal-plan/generate",
      {
        userId,
        days,
        useML: false,
      },
    );

    console.log("Meal plan generated:", response.data);
    return response.data;
  } catch (error) {
    console.error("Error:", error.response?.data || error.message);
  }
}

// Get recommended recipes
async function getRecommendedRecipes(userId, limit = 10) {
  try {
    const response = await axios.get(
      "http://localhost:3000/api/ai/recipes/recommended",
      {
        params: { userId, limit },
      },
    );

    console.log("Recommended recipes:", response.data);
    return response.data;
  } catch (error) {
    console.error("Error:", error.response?.data || error.message);
  }
}
```

### Python

```python
import requests

# Generate meal plan
def generate_meal_plan(user_id, days=7):
    url = 'http://localhost:3000/api/ai/meal-plan/generate'
    payload = {
        'userId': user_id,
        'days': days,
        'useML': False
    }

    response = requests.post(url, json=payload)

    if response.status_code == 201:
        print('Meal plan generated:', response.json())
        return response.json()
    else:
        print('Error:', response.json())
        return None

# Get recommended recipes
def get_recommended_recipes(user_id, limit=10):
    url = 'http://localhost:3000/api/ai/recipes/recommended'
    params = {
        'userId': user_id,
        'limit': limit
    }

    response = requests.get(url, params=params)

    if response.status_code == 200:
        print('Recommended recipes:', response.json())
        return response.json()
    else:
        print('Error:', response.json())
        return None
```

---

## Prerequisites

1. **User Data Required:**
   - User profile (age, gender, height, weight, goals)
   - Dietary preferences (optional)
   - Health metrics (calculated automatically)

2. **AI Service:**
   - Ensure AI service is running on `http://localhost:8000`
   - Check connection with `/api/ai/health` endpoint

3. **Environment Variables:**
   ```
   AI_SERVICE_URL=http://localhost:8000
   ```

---

## Integration Flow

1. **Setup User Profile:**
   - Create user profile with basic information
   - Set dietary preferences and restrictions
   - Calculate health metrics (BMI, BMR, TDEE)

2. **Generate Meal Plan:**
   - Call `/api/ai/meal-plan/generate` with user ID
   - Service collects all user data automatically
   - Sends to AI service for processing
   - Saves generated plan to database

3. **Retrieve Meal Plans:**
   - Use `/api/ai/meal-plans` to get all plans for a user
   - Plans are sorted by creation date (newest first)

4. **Get Recommendations:**
   - Call `/api/ai/recipes/recommended` for personalized recipes
   - Based on dietary preferences and restrictions

---

## Notes

- All timestamps are in ISO 8601 format (UTC)
- User IDs must be valid MongoDB ObjectIds
- Authentication middleware is commented out by default (add as needed)
- The service automatically handles data collection from multiple sources
- Error handling includes detailed logging for debugging
