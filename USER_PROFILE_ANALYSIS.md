# User Profile Analysis API

This document describes the `analyzeUserProfile` function implementation following the sequence diagram.

## Sequence Diagram Flow

```
Backend Service → DB: Load user profile + health data
DB → Backend Service: User data
Backend Service → AI API (FastAPI): analyzeUserProfile(profileData)
AI API → AI Core Service: analyze(profileData)
AI Core → Rule Engine/ML: Calculate BMR, TDEE, metabolic metrics
Rule Engine/ML → AI Core: Calculated metrics
AI Core → AI API: Analysis result
AI API → Backend Service: Structured analysis
Backend Service → DB: Save analysis result
```

## Endpoints

### Backend Endpoint

**POST** `/api/ai/user-profile/analyze`

**Request Body:**
```json
{
  "userId": "507f1f77bcf86cd799439011"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User profile analyzed and metrics saved successfully",
  "data": {
    "metrics": {
      "userId": "507f1f77bcf86cd799439011",
      "bmi": 24.5,
      "bmr": 1650.5,
      "tdee": 2557.28,
      "body_category": "normalweight",
      "calculatedAt": "2026-02-21T10:30:00.000Z",
      "source": "AI"
    },
    "analysis": {
      "user_id": "507f1f77bcf86cd799439011",
      "health_metrics": {
        "bmr": 1650.5,
        "tdee": 2557.28,
        "target_calories": 2057.28
      },
      "bmi": 24.5,
      "bmi_category": "normal_weight",
      "primary_health_goal": "weight_loss",
      "activity_level": "moderate",
      "analysis_summary": {
        "bmr_explanation": "Your body burns 1650.5 calories at rest",
        "tdee_explanation": "With moderate activity, you burn 2557.28 calories daily",
        "target_explanation": "To achieve weight_loss, target 2057.28 calories/day"
      },
      "source": "AI"
    }
  }
}
```

### AI Service Endpoint

**POST** `/api/v1/user-profile/analyze`

**Request Body:**
```json
{
  "user_id": "507f1f77bcf86cd799439011",
  "age": 30,
  "gender": "male",
  "height_cm": 175,
  "weight_kg": 75,
  "goal_weight_kg": 70,
  "health_goals": "weight_loss",
  "activity_level": "moderate"
}
```

**Response:**
```json
{
  "user_id": "507f1f77bcf86cd799439011",
  "health_metrics": {
    "bmr": 1650.5,
    "tdee": 2557.28,
    "target_calories": 2057.28
  },
  "bmi": 24.5,
  "bmi_category": "normal_weight",
  "primary_health_goal": "weight_loss",
  "activity_level": "moderate",
  "analysis_summary": {
    "bmr_explanation": "Your body burns 1650.5 calories at rest",
    "tdee_explanation": "With moderate activity, you burn 2557.28 calories daily",
    "target_explanation": "To achieve weight_loss, target 2057.28 calories/day"
  },
  "source": "AI"
}
```

## Implementation Details

### 1. Backend Service (`ai.services.js`)

Function: `analyzeUserProfileAndSave(userId)`

**Flow:**
1. Loads user profile from MongoDB
2. Prepares data for AI service
3. Calls AI API endpoint
4. Saves results to UserHealthMetrics collection
5. Returns success/error response

### 2. AI Client (`aiClient.js`)

Function: `analyzeUserProfile(userProfile)`

**Responsibilities:**
- HTTP communication with FastAPI service
- Error handling and logging
- Request/response interceptors

### 3. AI API Endpoint (`user_analysis.py`)

Function: `analyze_user_profile_endpoint(payload)`

**Validations:**
- Activity level: sedentary, light, moderate, active, very_active
- Gender: male, female, other
- Age, height, weight ranges

**Processing:**
- Converts request to UserProfile domain model
- Calls AI Core service
- Returns structured response

### 4. AI Core Service (`bmr_tdee_calculator.py`)

Function: `analyze_user_profile(user, health_goals)`

**Calculations:**
1. **BMR (Basal Metabolic Rate)** - Mifflin-St Jeor equation
   - Male: BMR = 10×weight(kg) + 6.25×height(cm) - 5×age + 5
   - Female: BMR = 10×weight(kg) + 6.25×height(cm) - 5×age - 161

2. **TDEE (Total Daily Energy Expenditure)**
   - Sedentary: BMR × 1.2
   - Light: BMR × 1.375
   - Moderate: BMR × 1.55
   - Active: BMR × 1.725
   - Very Active: BMR × 1.9

3. **Target Calories**
   - Weight loss: TDEE - 500
   - Aggressive weight loss: TDEE - 750
   - Weight gain: TDEE + 500
   - Muscle gain: TDEE + 300
   - Maintenance: TDEE

4. **BMI (Body Mass Index)**
   - BMI = weight(kg) / (height(m))²
   - Categories: underweight (<18.5), normal (18.5-25), overweight (25-30), obese (≥30)

## Usage Examples

### Example 1: Analyze User Profile via Backend

```bash
curl -X POST http://localhost:3000/api/ai/user-profile/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "507f1f77bcf86cd799439011"
  }'
```

### Example 2: Direct AI Service Call

```bash
curl -X POST http://localhost:8000/api/v1/user-profile/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user_123",
    "age": 25,
    "gender": "female",
    "height_cm": 165,
    "weight_kg": 60,
    "goal_weight_kg": 55,
    "health_goals": "weight_loss",
    "activity_level": "light"
  }'
```

### Example 3: JavaScript/Node.js

```javascript
const axios = require('axios');

async function analyzeUserProfile(userId) {
  try {
    const response = await axios.post(
      'http://localhost:3000/api/ai/user-profile/analyze',
      { userId }
    );
    
    console.log('Analysis Result:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

analyzeUserProfile('507f1f77bcf86cd799439011');
```

## Testing

You can test the endpoint using:

1. **Swagger UI**: http://localhost:8000/docs
   - Navigate to "user-analysis" section
   - Click "Try it out" on POST /api/v1/user-profile/analyze
   - Fill in the request body
   - Click "Execute"

2. **Backend API**: Use Postman, curl, or any HTTP client
   - POST to http://localhost:3000/api/ai/user-profile/analyze
   - Include valid MongoDB ObjectId in userId field

## Database Schema

### UserHealthMetrics Collection

```javascript
{
  userId: String,           // User ID reference
  bmi: Number,             // Body Mass Index
  bmr: Number,             // Basal Metabolic Rate
  tdee: Number,            // Total Daily Energy Expenditure
  body_category: String,   // underweight, normal, overweight, obese
  calculatedAt: Date,      // When metrics were calculated
  source: String           // AI or Nutritionist
}
```

## Error Handling

The implementation includes comprehensive error handling:

- **400 Bad Request**: Invalid input data (activity level, gender, etc.)
- **404 Not Found**: User profile not found
- **500 Internal Server Error**: AI service unavailable or calculation errors
- **503 Service Unavailable**: AI service is down

## Activity Levels

- **sedentary**: Little or no exercise
- **light**: Light exercise 1-3 days/week
- **moderate**: Moderate exercise 3-5 days/week
- **active**: Hard exercise 6-7 days/week
- **very_active**: Very hard exercise, physical job

## Health Goals

- **weight_loss**: 1 lb/week loss (-500 cal)
- **aggressive_weight_loss**: 1.5 lb/week loss (-750 cal)
- **weight_gain**: 1 lb/week gain (+500 cal)
- **muscle_gain**: Lean muscle gain (+300 cal)
- **maintenance**: Maintain current weight (0 cal adjustment)

## Next Steps

1. Add authentication middleware to protect the endpoint
2. Implement caching for frequently analyzed profiles
3. Add history tracking for metric changes over time
4. Integrate with meal planning based on calculated TDEE
5. Add notifications when metrics indicate health concerns
