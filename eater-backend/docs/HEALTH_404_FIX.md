# Fix: 404 Health Information Not Found

## Problem
When testing health endpoints, you get:
```
[ERROR] 404 - Health information not found
```

## Root Cause
The health profile **doesn't exist** in the database yet for that userId.

The flow must be:
1. **CREATE** health info first (POST) → Returns 201
2. **GET** the health info (GET) → Returns 200
3. **UPDATE** the health info (PUT) → Returns 200
4. **DELETE** the health info (DELETE) → Returns 204

## Solution

### Step 1: Seed Sample Data
Before testing, create sample health data:
```bash
npm run seed:health
```

Output:
```
✅ Sample health profile created successfully
   UserId: 507f1f77bcf86cd799439011
   Age: 30, Gender: male, Weight: 75kg
```

### Step 2: Use Correct UserId in Postman
Make sure to use the **exact** userId from seeded data:
```
UserId: 507f1f77bcf86cd799439011
```

In Postman, set the variable:
1. Collections → Health Information API
2. Variables tab
3. Set `userId` = `507f1f77bcf86cd799439011`

### Step 3: Test Flow in Postman

**Option A: Create New Profile**
```
POST http://localhost:3000/api/v1/health/507f1f77bcf86cd799439011
Content-Type: application/json

{
  "age": 28,
  "gender": "female",
  "height": 165,
  "weight": 60,
  "activityLevel": "light"
}
```
Expected: **201 Created**

**Option B: Use Seeded Data**
```
GET http://localhost:3000/api/v1/health/507f1f77bcf86cd799439011
```
Expected: **200 OK** with data

### Step 4: Common Mistakes

❌ **Wrong**: Using different userId than what you created
```
# This will fail if you created profile for 507f1f77bcf86cd799439011
GET http://localhost:3000/api/v1/health/DIFFERENT_ID
```

❌ **Wrong**: Trying to GET before POST
```
# This will fail:
POST /api/v1/health/newUserID  (create)
GET /api/v1/health/oldUserID   (get - doesn't exist!)
```

✅ **Correct**: Same userId throughout
```
POST /api/v1/health/507f1f77bcf86cd799439011  (create)
GET /api/v1/health/507f1f77bcf86cd799439011   (get - works!)
PUT /api/v1/health/507f1f77bcf86cd799439011   (update)
DELETE /api/v1/health/507f1f77bcf86cd799439011 (delete)
```

### Step 5: Verify in MongoDB

Open MongoDB Compass:
1. Connect to `mongodb://127.0.0.1:27017`
2. Go to `ai_healthy_meal_planner` database
3. Look for `user_profiles` collection
4. Should have a document with userId: `507f1f77bcf86cd799439011`

If collection is empty → run `npm run seed:health` again

### Summary

| Issue | Cause | Fix |
|-------|-------|-----|
| 404 on GET | Profile doesn't exist | Run `npm run seed:health` or POST create first |
| 404 on UPDATE | Profile doesn't exist | Create profile first with POST |
| 404 on DELETE | Profile doesn't exist | Create profile first with POST |
| Validation error 400 | Invalid data format | Check Postman payload matches schema |
| Wrong UserId | Copy-paste error | Use exact UserId: `507f1f77bcf86cd799439011` |

---

## Quick Test Workflow

```bash
# 1. Start server
npm run dev

# 2. In another terminal, seed data
npm run seed:health

# 3. Open Postman & test:
# - GET http://localhost:3000/api/v1/health/507f1f77bcf86cd799439011
# - PUT with new weight
# - DELETE when done
```

Done! 🚀
