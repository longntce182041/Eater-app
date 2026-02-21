# AI Service Connection Guide

## ✅ Services Connected Successfully!

The Node.js backend is now fully connected to the Python AI meal planning service.

---

## 🏗️ Architecture

```
┌─────────────────────┐
│   Frontend/Mobile   │
│  (React/Flutter)    │
└──────────┬──────────┘
           │ HTTP
           ▼
┌─────────────────────┐
│   Node.js Backend   │
│   (Port 3000)       │
│  - Express API      │
│  - MongoDB          │
│  - User Management  │
└──────────┬──────────┘
           │ HTTP (Axios)
           ▼
┌─────────────────────┐
│  Python AI Service  │
│   (Port 8000)       │
│  - FastAPI          │
│  - Meal Planning    │
│  - Nutrition Calc   │
└─────────────────────┘
```

---

## 🚀 Quick Start

### Option 1: Use the startup script (Windows)

```bash
start-services.bat
```

### Option 2: Manual startup

**1. Start MongoDB:**
```bash
mongod
```

**2. Start Python AI Service:**
```bash
cd ai_meal_planing_service
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

**3. Start Node.js Backend:**
```bash
cd eater-backend
npm install
npm run dev
```

**4. Test Connection:**
```bash
node test-ai-connection.js
```

---

## 📡 API Endpoints

### Node.js Backend → Frontend/Mobile

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/ai/meal-plan/generate` | Generate meal plan |
| GET | `/api/ai/meal-plans` | Get user meal plans |
| GET | `/api/ai/recipes/recommended` | Get recommendations |
| GET | `/api/ai/user-data` | Get formatted user data |
| GET | `/api/ai/health` | Check AI service health |
| GET | `/api/ai/status` | Get AI service status |

### Python AI Service (Internal)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/health` | Health check |
| POST | `/api/v1/meal-planning/generate` | Generate meal plan |

---

## 🔧 Configuration

### Backend (.env)
```env
PORT=3000
AI_SERVICE_URL=http://localhost:8000
MONGODB_URI=mongodb://127.0.0.1:27017/ai_healthy_meal_planner
```

### AI Service (.env)
```env
PORT=8000
BACKEND_BASE_URL=http://localhost:3000
API_V1_PREFIX=/api/v1
```

---

## 💡 How It Works

### 1. Request Flow

```
Frontend → Backend → AI Service → Backend → Frontend
```

**Example Request:**

```javascript
// Frontend calls backend
fetch('http://localhost:3000/api/ai/meal-plan/generate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: '507f1f77bcf86cd799439011',
    days: 7,
    useML: false
  })
})
```

**Backend processes and forwards to AI Service:**

```javascript
// Backend (ai.services.js)
const userData = await prepareUserDataForAI(userId);
const payload = {
  user_id: userId,
  days: days,
  use_ml: useML,
  user_data: userData  // Includes profile, preferences, health metrics
};

// Call AI service via aiClient
const response = await aiClient.generateMealPlan(payload);
```

**AI Service generates meal plan:**

```python
# Python AI Service (meal_planning.py)
@router.post("/generate")
async def generate_meal_plan(payload: GenerateMealPlanRequest):
    # Generate meal plan based on user data
    meal_plan = generate_optimized_plan(payload)
    return MealPlanResponse(...)
```

### 2. Data Collection

The backend automatically collects:
- ✅ User profile (age, gender, height, weight, goals)
- ✅ Dietary preferences (diet type, allergens, restrictions)
- ✅ Health metrics (BMI, BMR, TDEE)
- ✅ Excluded ingredients

### 3. Error Handling

Both services include:
- Request/response interceptors for logging
- Comprehensive error handling
- Detailed error messages
- Connection retry logic

---

## 🧪 Testing

### Test Connection

```bash
node test-ai-connection.js
```

This will test:
1. ✓ AI Service health check
2. ✓ AI Service root endpoint
3. ✓ Backend health check  
4. ✓ Backend → AI Service connection
5. ✓ Direct meal plan generation
6. ✓ Meal plan generation via backend

### Manual Testing

**Test AI Service directly:**
```bash
curl http://localhost:8000/api/v1/health
```

**Test through backend:**
```bash
curl http://localhost:3000/api/ai/health
```

**Generate meal plan:**
```bash
curl -X POST http://localhost:3000/api/ai/meal-plan/generate \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test_user_123",
    "days": 7,
    "useML": false
  }'
```

---

## 📝 Code Examples

### Backend Service Usage

```javascript
const aiService = require('./src/api/services/ai.services');

// Generate meal plan
async function createMealPlan(userId) {
  const result = await aiService.generateAndSaveMealPlan(userId, {
    days: 7,
    useML: false
  });
  
  if (result.success) {
    return result.mealPlan;
  }
  throw new Error(result.error);
}

// Get user data
const userData = await aiService.prepareUserDataForAI(userId);

// Get recommendations
const recipes = await aiService.getRecommendedRecipes(userId, 10);
```

### Direct AI Client Usage

```javascript
const { generateMealPlan, healthCheck } = require('./src/integrations/ai/aiClient');

// Check if AI service is available
const health = await healthCheck();

// Generate meal plan
const response = await generateMealPlan({
  user_id: "123",
  days: 7,
  use_ml: false,
  user_data: { /* ... */ }
});
```

---

## 🐛 Troubleshooting

### AI Service not responding

```bash
# Check if service is running
curl http://localhost:8000

# Check logs
tail -f logs/ai-service.log
```

### Backend can't connect to AI Service

1. Verify AI service is running on port 8000
2. Check `AI_SERVICE_URL` in backend `.env`
3. Ensure no firewall blocking localhost:8000
4. Check logs: `logs/backend.log`

### MongoDB connection issues

```bash
# Check if MongoDB is running
mongo --eval "db.adminCommand('ping')"

# Verify connection string in .env
MONGODB_URI=mongodb://127.0.0.1:27017/ai_healthy_meal_planner
```

### Port already in use

```bash
# Kill process on port 8000
# Windows: netstat -ano | findstr :8000
# Linux/Mac: lsof -ti:8000 | xargs kill -9

# Kill process on port 3000
# Windows: netstat -ano | findstr :3000
# Linux/Mac: lsof -ti:3000 | xargs kill -9
```

---

## 📚 Documentation

- `AI_SERVICE_API.md` - Complete API documentation
- `AI_SERVICE_SETUP.md` - Setup guide
- `test-ai-connection.js` - Connection test script
- `ai-service-examples.js` - Usage examples

---

## ✨ Features Implemented

### Backend (Node.js)
- ✅ AI service client with axios
- ✅ Request/response interceptors
- ✅ Comprehensive error handling
- ✅ Data collection from multiple sources
- ✅ REST API endpoints
- ✅ Input validation
- ✅ Health checks

### AI Service (Python)
- ✅ FastAPI application
- ✅ CORS configuration
- ✅ Health endpoint
- ✅ Meal planning endpoint (mock implementation)
- ✅ Pydantic schemas
- ✅ Error handling
- ✅ Logging

---

## 🎯 Next Steps

1. **Implement Full Meal Planning Logic**
   - Connect to recipe database
   - Implement nutrition calculator
   - Add optimization algorithms

2. **Add Authentication**
   - JWT token validation
   - User authorization

3. **Enhanced Features**
   - ML/LLM integration
   - Recipe recommendations
   - Nutrition tracking

4. **Testing**
   - Unit tests
   - Integration tests
   - Load testing

---

## 🎉 Success!

Your backend is now successfully connected to the AI meal planning service! 

Both services are communicating properly through HTTP requests, with proper error handling, logging, and data validation in place.

**Services Running:**
- 🟢 AI Service: http://localhost:8000
- 🟢 Backend: http://localhost:3000

**Test it now:**
```bash
node test-ai-connection.js
```
