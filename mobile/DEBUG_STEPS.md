# Debug Steps for Login 404 Issue on Flutter Web

## Changes Made

1. ✅ Enhanced logging in `env_loader.dart` for web platform detection
2. ✅ Added detailed logging in `auth_api_client.dart` to show exact URLs
3. ✅ Added login start log in `auth_providers.dart`
4. ✅ Verified backend CORS is enabled (wildcard allowed)

## Next Steps - FOLLOW THESE EXACTLY:

### Step 1: Complete App Restart

```bash
# Stop the app completely (Ctrl+C in terminal)
# Then run:
cd /Users/tranphantrungkien/Ky8/WDP301/Eater-app/mobile
flutter clean
flutter pub get
flutter run -d chrome --web-port 3001
```

**Important:** Use port 3001 for Flutter web to avoid conflicts with backend on 3000

### Step 2: Login and Capture Logs

1. Open browser console (F12 → Console tab)
2. In Flutter app, click login
3. **Copy ALL console output** that contains these emojis:
   - 🌐 (Platform/Network logs)
   - 🔐 (Auth logs)
   - 🛒 (Grocery logs)

### Step 3: What to Look For

The logs should show:

```
🌐 Platform: WEB BROWSER
🌐 API Base URL: http://localhost:3000
🌐 Creating Dio with baseUrl: http://localhost:3000
🔐 Starting login for: your-email@test.com
🌐 API login baseUrl: http://localhost:3000
🌐 API login path: /api/auth/user/login
🌐 API login full URL: http://localhost:3000/api/auth/user/login
🌐 Dio: *** Request ***
🌐 Dio: uri: http://localhost:3000/api/auth/user/login
🌐 Dio: method: POST
```

**If you see 404:**

- Check the "uri:" line - does it show the correct URL?
- Check browser Network tab (F12 → Network) - what URL was actually requested?
- Screenshot both console and network tab

### Step 4: Check Backend

Make sure backend is running:

```bash
cd /Users/tranphantrungkien/Ky8/WDP301/Eater-app/eater-backend
npm start
```

Should see: `Server started on port 3000`

### Step 5: Test Backend Directly from Browser

Open a new tab and paste this in the address bar:

```
http://localhost:3000/api/auth/user/login
```

Expected: Should see: `Cannot GET /api/auth/user/login` (because it's POST only)
If you see 404: Backend routing problem

### Potential Issues & Solutions

**Issue 1: Port Conflict**

- Symptom: Flutter web trying to use port 3000
- Solution: Use `flutter run -d chrome --web-port 3001`

**Issue 2: CORS Preflight**

- Symptom: Browser blocks request before it reaches backend
- Solution: Check browser console for CORS error (red text)
- Backend already has CORS enabled, but check .env file for ALLOWED_ORIGINS

**Issue 3: Dio baseUrl not set on Web**

- Symptom: Logs show baseUrl is null or empty
- Solution: Already fixed in env_loader.dart, but verify with logs

**Issue 4: Relative path concatenation**

- Symptom: URL shows "http://localhost:3001/api/..." instead of 3000
- Solution: Verify \_dio.options.baseUrl in logs

**Issue 5: Flutter web needs rebuild**

- Symptom: Changes not taking effect
- Solution: Run `flutter clean` and rebuild

## Send Me These 3 Things:

1. **Console logs** (all 🌐 🔐 emoji logs)
2. **Network tab screenshot** (F12 → Network, filter for "login")
3. **Full error message** from console

Then I can pinpoint the exact issue!
