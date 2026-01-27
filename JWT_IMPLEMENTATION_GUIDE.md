# JWT Token Flow Implementation - Setup Summary

## Changes Made

### Mobile App (Flutter/Dart)

1. **Token Storage Integration** (`auth_notifier.dart`)
   - On app startup, loads tokens from secure storage into `authTokenProvider`
   - This ensures tokens are available immediately when the Dio interceptor runs

2. **Dio Interceptor** (`dio_provider.dart`)
   - Watches `authTokenProvider` for tokens
   - Automatically adds `Authorization: Bearer <token>` header to all requests
   - Debug logging shows when tokens are added or missing

3. **Auth Controller** (`auth_providers.dart`)
   - After successful login/register, stores tokens in both:
     - Secure storage (TokenStorage)
     - `authTokenProvider` (for Dio interceptor)
   - Fixed syntax errors in register() method

4. **Profile Setup** (`profile_setup_provider.dart`)
   - Uses relative path `/api/health/user-profile` instead of absolute URL
   - This ensures the Dio baseUrl + interceptor work correctly

### Backend (Node/Express)

1. **Auth Middleware** (`authMiddleware.js`)
   - Extracts token from `Authorization: Bearer <token>` header
   - Returns 401 "Authentication token missing" if no token
   - Returns 401 "Invalid or expired token" if token verification fails

2. **Health Controller** (`health.user.controller.js`)
   - Validates `req.user` exists before processing requests
   - Returns 401 "User authentication required" if token validation failed

3. **Health Routes** (`health.routes.js`)
   - Protected `/api/health/user-profile` (POST) with `protect` middleware
   - New test endpoint: `GET /api/health/test-auth` (protected, no DB access)
   - JWT_SECRET: "dev-secret" (for development)

## Token Flow Sequence

```
1. User registers/logins
   ↓
2. Backend returns { accessToken, refreshToken, user }
   ↓
3. Mobile AuthController stores in TokenStorage + authTokenProvider
   ↓
4. User navigates to profile setup
   ↓
5. Dio interceptor sees authTokenProvider has tokens
   ↓
6. Adds "Authorization: Bearer <token>" to POST /api/health/user-profile
   ↓
7. Backend protect middleware verifies token
   ↓
8. Request proceeds with req.user populated
```

## Verification Steps

### 1. Test Backend Token Verification
Generate a valid JWT and test:
```bash
cd eater-backend
node -e "const jwt = require('jsonwebtoken'); console.log(jwt.sign({id:'test-user',role:'user'},'dev-secret',{expiresIn:'1h'}));"
```

Then test the endpoint:
```bash
curl -X GET http://localhost:3000/api/health/test-auth \
  -H "Authorization: Bearer <TOKEN_FROM_ABOVE>"
```

Expected: `{"message":"Authentication successful","userId":"test-user","role":"user"}`

### 2. Test Mobile App  
1. Run the Flutter app
2. Register/Login with credentials
3. Navigate to profile setup
4. Watch console logs (should see "Making request to: /api/health/user-profile")
5. Should see "Added Authorization header to request" in logs
6. Profile should submit successfully (200 OK)

### 3. Common Issues & Fixes

**Issue**: Still getting 401
- Check Dio logs: "No access token available" = tokens not in authTokenProvider
- Check auth_notifier: tokens not loading from secure storage
- Check register/login: tokens not being saved to secure storage

**Issue**: 401 "Invalid or expired token"
- Token might be using different secret than backend
- Token might be expired
- Generate fresh token and test with curl first

**Issue**: Backend crashes on request
- Check MongoDB connection
- Verify User_Profile model exists and has proper schema
- Check for unhandled promise rejections in service layer

## Key Files Modified

Mobile:
- `mobile/lib/src/config/router/auth_notifier.dart`
- `mobile/lib/src/shared/providers/dio_provider.dart`  
- `mobile/lib/src/shared/providers/auth_token_provider.dart`
- `mobile/lib/src/features/auth/presentation/providers/auth_providers.dart`
- `mobile/lib/src/features/userHeath/presentation/providers/profile_setup_provider.dart`

Backend:
- `eater-backend/src/middleware/authMiddleware.js`
- `eater-backend/src/api/controllers/health.user.controller.js`
- `eater-backend/src/api/routes/health.routes.js`
