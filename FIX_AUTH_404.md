## 🔧 Fix Authentication 404 Error

### ❌ Problem

```
404 (Not Found) when trying to login
Status code 404 - Client error
```

### 🔍 Root Cause

The app is trying to connect to `localhost:3000` but:

- **On iOS Simulator**: `localhost` works ✅
- **On Android Emulator**: Need `10.0.2.2` (host = Android) ✅
- **On Physical Device** (iPhone/iPad): `localhost` does NOT work ❌
  - Physical devices cannot access your Mac's `localhost`
  - Need your Mac's actual IP address: **192.168.1.248**

### ✅ Solution

**Option 1: Quick Test (Temporary Fix)**

Edit `mobile/lib/src/config/env/env_loader.dart`:

```dart
String base = 'http://192.168.1.248:3000';  // ← Use Mac IP for physical device
```

**Option 2: Auto-detect (Recommended)**

The code now has smart detection:

- iOS Simulator → `localhost:3000`
- Android Emulator → `10.0.2.2:3000`
- Physical Device → Need to manually set IP

**Update to use Mac IP for physical device:**

```dart
class EnvLoader {
  static AppConfig load() {
    String base;

    if (!kIsWeb) {
      try {
        final isAndroid = Platform.isAndroid;
        if (isAndroid) {
          base = 'http://10.0.2.2:3000';  // Android emulator
        } else {
          // iOS: Check if physical device by trying to detect
          // For now, use localhost (works for simulator)
          // If on physical device, change to: 'http://192.168.1.248:3000'
          base = 'http://localhost:3000';
        }
      } catch (e) {
        base = 'http://localhost:3000';
      }
    } else {
      base = 'http://localhost:3000';
    }

    return AppConfig(apiBaseUrl: base);
  }
}
```

### 📱 Testing Scenarios

| Device Type       | Base URL                    | Works? |
| ----------------- | --------------------------- | ------ |
| iOS Simulator     | `http://localhost:3000`     | ✅ Yes |
| Android Emulator  | `http://10.0.2.2:3000`      | ✅ Yes |
| iPhone (Physical) | `http://192.168.1.248:3000` | ✅ Yes |
| iPad (Physical)   | `http://192.168.1.248:3000` | ✅ Yes |

### 🧪 How to Test

1. **Check your device type:**
   - Look at console logs for: `🌐 Platform: Android` or `🌐 Platform: iOS/Other`
   - Check: `🌐 API Base URL: http://...`

2. **If testing on PHYSICAL DEVICE:**

   ```dart
   // Change this line in env_loader.dart:
   base = 'http://192.168.1.248:3000';  // ← Your Mac's IP
   ```

3. **Restart the app** (full stop and run, not hot reload)

4. **Try login again**

5. **Check console logs:**
   ```
   🌐 Platform: iOS/Other
   🌐 API Base URL: http://192.168.1.248:3000
   🌐 Creating Dio with baseUrl: http://192.168.1.248:3000
   🌐 Dio: *** request ***
   🌐 Dio: uri: http://192.168.1.248:3000/api/auth/user/login
   🌐 Dio: method: POST
   ```

### ⚙️ Backend Verification

Backend is running correctly:

```bash
$ lsof -i :3000
node 19395 ... *:3000 (LISTEN) ✅
```

Endpoint structure:

- Base: `http://localhost:3000`
- Route: `/api/auth/user/login`
- Full URL: `http://localhost:3000/api/auth/user/login`

### 🔑 Your Mac's IP Address

Your current Mac IP: **192.168.1.248**

To find it anytime:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
```

### 📝 Backend Routes (Confirmed Working)

- ✅ POST `/api/auth/user/register`
- ✅ POST `/api/auth/user/login`
- ✅ POST `/api/auth/user/verify-email`
- ✅ POST `/api/auth/user/request-password-reset`
- ✅ POST `/api/auth/user/reset-password`
- ✅ POST `/api/auth/user/refresh`
- ✅ POST `/api/auth/user/logout`

All routes are correctly configured in:

- `app.js`: `app.use('/api', Routes)`
- `routes/index.js`: `router.use('/auth/user', authUserRoutes)`
- `routes/auth.routes.js`: `router.post('/login', ...)`

### ✅ Next Steps

1. **Determine your test device:**
   - iOS Simulator? → Keep `localhost:3000` ✅
   - Android Emulator? → Already set to `10.0.2.2:3000` ✅
   - Physical iPhone/iPad? → Change to `192.168.1.248:3000` ⚠️

2. **Update env_loader.dart if needed**

3. **Full restart app** (Stop + Run)

4. **Check console logs** - should see successful connection

5. **Login should work!** ✅
