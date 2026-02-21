# AI Service Integration - Quick Start Guide

## ✅ What Has Been Implemented

### 1. **AI Service Layer** (`src/api/services/ai.services.js`)
Complete service with functions to:
- ✅ Fetch user profile, dietary preferences, and health metrics
- ✅ Prepare user data for AI processing
- ✅ Generate AI meal plans
- ✅ Save meal plans to database
- ✅ Get user meal plans history
- ✅ Get recommended recipes based on preferences
- ✅ Complete workflow with error handling

### 2. **AI Client** (`src/integrations/ai/aiClient.js`)
Enhanced HTTP client with:
- ✅ Axios instance configured for AI service
- ✅ Request/response interceptors for logging
- ✅ Error handling
- ✅ Health check endpoint
- ✅ Service status endpoint

### 3. **API Controller** (`src/api/controllers/ai.controller.js`)
REST API controllers for:
- ✅ Generate meal plan
- ✅ Get user meal plans
- ✅ Get recommended recipes
- ✅ Get user data for AI
- ✅ Check AI service health
- ✅ Get AI service status

### 4. **Routes** (`src/api/routes/ai.routes.js`)
API endpoints registered at `/api/ai`:
- ✅ `POST /meal-plan/generate` - Generate meal plan
- ✅ `GET /meal-plans` - Get user meal plans
- ✅ `GET /recipes/recommended` - Get recommendations
- ✅ `GET /user-data` - Get formatted user data
- ✅ `GET /health` - Health check
- ✅ `GET /status` - Service status

### 5. **Validation** (`src/api/validators/ai.validators.js`)
Request validation middleware for:
- ✅ Meal plan generation parameters
- ✅ Query parameters validation
- ✅ User ID format validation

### 6. **Documentation**
- ✅ `AI_SERVICE_API.md` - Complete API documentation
- ✅ `ai-service-examples.js` - Usage examples and test code

---

## 🚀 How to Use

### Quick Test

1. **Start your MongoDB server**
   ```bash
   # Make sure MongoDB is running
   mongod
   ```

2. **Start the AI meal planning service** (Python FastAPI)
   ```bash
   cd ai_meal_planing_service
   uvicorn app.main:app --reload --port 8000
   ```

3. **Start your Node.js backend**
   ```bash
   cd eater-backend
   npm run dev
   ```

4. **Test with cURL or Postman**

   **Generate a meal plan:**
   ```bash
   curl -X POST http://localhost:3000/api/ai/meal-plan/generate \
     -H "Content-Type: application/json" \
     -d '{
       "userId": "YOUR_USER_ID_HERE",
       "days": 7,
       "useML": false
     }'
   ```

   **Get user meal plans:**
   ```bash
   curl http://localhost:3000/api/ai/meal-plans?userId=YOUR_USER_ID_HERE&limit=10
   ```

   **Check AI service health:**
   ```bash
   curl http://localhost:3000/api/ai/health
   ```

---

## 📝 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/ai/meal-plan/generate` | Generate AI meal plan |
| GET | `/api/ai/meal-plans` | Get user's meal plans |
| GET | `/api/ai/recipes/recommended` | Get recommended recipes |
| GET | `/api/ai/user-data` | Get formatted user data |
| GET | `/api/ai/health` | Check AI service health |
| GET | `/api/ai/status` | Get AI service status |

---

## 💻 Code Usage Examples

### In Your Controllers/Services:

```javascript
const aiService = require('./src/api/services/ai.services');

// Generate meal plan
async function createMealPlanForUser(userId) {
  const result = await aiService.generateAndSaveMealPlan(userId, {
    days: 7,
    useML: false
  });
  
  if (result.success) {
    console.log('Meal plan created:', result.mealPlan);
    return result.mealPlan;
  } else {
    console.error('Error:', result.error);
    throw new Error(result.error);
  }
}

// Get user data
async function getUserAIData(userId) {
  const userData = await aiService.prepareUserDataForAI(userId);
  return userData;
}

// Get recommendations
async function getRecipes(userId) {
  const recipes = await aiService.getRecommendedRecipes(userId, 10);
  return recipes;
}
```

---

## 🔧 Configuration

### Environment Variables

Make sure these are set in your `.env` file:

```env
AI_SERVICE_URL=http://localhost:8000
MONGODB_URI=mongodb://127.0.0.1:27017/ai_healthy_meal_planner
```

---

## ✨ Features

### Data Collection
The service automatically collects:
- ✅ User profile (age, gender, height, weight, goals)
- ✅ Dietary preferences (diet type, allergens, restrictions)
- ✅ Health metrics (BMI, BMR, TDEE)
- ✅ Excluded ingredients

### Error Handling
- ✅ Comprehensive try-catch blocks
- ✅ Detailed error logging
- ✅ User-friendly error messages
- ✅ AI service connection error handling

### Validation
- ✅ Request parameter validation
- ✅ MongoDB ObjectId validation
- ✅ Range validation for numeric parameters

---

## 📚 Next Steps

1. **Add Authentication**
   - Uncomment authentication middleware in routes
   - Protect endpoints that require user login

2. **Enhance AI Integration**
   - Implement ML/LLM features when ready
   - Add more AI service endpoints as available

3. **Add More Features**
   - Meal plan rating/feedback
   - Recipe favorites
   - Meal plan sharing
   - Nutrition tracking

4. **Testing**
   - Run the example file: `node ai-service-examples.js`
   - Write unit tests for services
   - Add integration tests

---

## 🐛 Troubleshooting

### AI Service Not Available
```bash
# Check if AI service is running
curl http://localhost:8000/api/v1/health

# Check backend can reach it
curl http://localhost:3000/api/ai/health
```

### User Data Not Found
- Ensure user profile exists in database
- Check user ID format (must be valid MongoDB ObjectId)
- Verify dietary preferences are set

### Database Connection Issues
- Ensure MongoDB is running
- Check `MONGODB_URI` in `.env`
- Verify database name matches

---

## 📖 Documentation Files

- `AI_SERVICE_API.md` - Complete API documentation with examples
- `ai-service-examples.js` - Runnable code examples
- This file - Quick start guide

---

## 🎯 Summary

You now have a complete AI service integration that:
1. ✅ Collects user data from multiple sources
2. ✅ Sends data to AI service for processing
3. ✅ Saves generated meal plans
4. ✅ Provides recommendations
5. ✅ Includes full API endpoints
6. ✅ Has validation and error handling
7. ✅ Is fully documented with examples

**Ready to use!** 🚀
