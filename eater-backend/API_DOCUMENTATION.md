# API Documentation

## Authentication Endpoints

### Base URL

```
http://localhost:3000/api/auth
```

## 1. Register Account

**Endpoint:** `POST /api/auth/register`

**Description:** Tạo tài khoản mới cho người dùng

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Validation Rules:**

- Email: Phải là email hợp lệ
- Password: Tối thiểu 8 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, và 1 số

**Response (201 Created):**

```json
{
  "status": "success",
  "message": "Account created successfully. Please verify your email.",
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "role": "user",
      "isEmailVerified": false,
      "createdAt": "2026-01-23T10:00:00.000Z"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token",
    "emailVerificationToken": "verification_token_here"
  }
}
```

**Error Responses:**

- `409 Conflict`: Email đã tồn tại
- `400 Bad Request`: Validation errors

---

## 2. Verify Email

**Endpoint:** `POST /api/auth/verify-email`

**Description:** Xác thực email của người dùng bằng verification token

**Request Body:**

```json
{
  "token": "email_verification_token"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "message": "Email verified successfully"
}
```

**Error Responses:**

- `400 Bad Request`: Token không hợp lệ hoặc đã hết hạn
- `400 Bad Request`: Email đã được xác thực trước đó

---

## 3. User Login

**Endpoint:** `POST /api/auth/login`

**Description:** Đăng nhập và nhận JWT tokens

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "role": "user",
      "isEmailVerified": true,
      "createdAt": "2026-01-23T10:00:00.000Z"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

**Error Responses:**

- `401 Unauthorized`: Email hoặc password không đúng
- `403 Forbidden`: Tài khoản bị deactivate

---

## 4. Logout

**Endpoint:** `POST /api/auth/logout`

**Description:** Đăng xuất người dùng

**Request Body:**

```json
{
  "refreshToken": "jwt_refresh_token"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

---

## 5. Request Password Reset

**Endpoint:** `POST /api/auth/request-password-reset`

**Description:** Yêu cầu reset password, hệ thống sẽ tạo reset token

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "message": "If the email exists, a password reset link has been sent",
  "passwordResetToken": "reset_token_here"
}
```

**Note:** Trong production, token sẽ được gửi qua email, không trả về trong response.

---

## 6. Reset Password

**Endpoint:** `POST /api/auth/reset-password`

**Description:** Đặt lại mật khẩu mới bằng reset token

**Request Body:**

```json
{
  "token": "password_reset_token",
  "newPassword": "NewPassword123"
}
```

**Validation Rules:**

- newPassword: Tối thiểu 8 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, và 1 số

**Response (200 OK):**

```json
{
  "status": "success",
  "message": "Password reset successfully"
}
```

**Error Responses:**

- `400 Bad Request`: Token không hợp lệ hoặc đã hết hạn

---

## 7. Refresh Token

**Endpoint:** `POST /api/auth/refresh`

**Description:** Làm mới access token bằng refresh token

**Request Body:**

```json
{
  "refreshToken": "jwt_refresh_token"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "data": {
    "accessToken": "new_jwt_access_token",
    "refreshToken": "new_jwt_refresh_token"
  }
}
```

**Error Responses:**

- `401 Unauthorized`: Refresh token không hợp lệ hoặc đã hết hạn
- `404 Not Found`: User không tồn tại
- `403 Forbidden`: Tài khoản bị deactivate

---

## JWT Token Usage

Sau khi login hoặc register thành công, bạn sẽ nhận được:

- `accessToken`: Sử dụng để authenticate các protected endpoints (expires in 1 hour)
- `refreshToken`: Sử dụng để refresh access token (expires in 7 days)

**Header format cho protected endpoints:**

```
Authorization: Bearer <accessToken>
```

---

## Testing với Postman

1. Import file `Eater_Backend_Auth.postman_collection.json` vào Postman
2. Đảm bảo server đang chạy: `npm run dev` hoặc `npm start`
3. Base URL: `http://localhost:3000`
4. Test theo thứ tự:
   - Register → Verify Email → Login → Logout
   - Hoặc: Register → Login → Request Password Reset → Reset Password

---

## Mobile App Integration

### Base URL Configuration

```dart
// Flutter/Dart
const String BASE_URL = 'http://localhost:3000/api';
// Hoặc khi deploy: 'https://your-domain.com/api'
```

### Example API Call (Flutter/Dio)

```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://localhost:3000/api',
  headers: {'Content-Type': 'application/json'},
));

// Register
Future<void> register(String email, String password) async {
  try {
    final response = await dio.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
    // Save tokens
    final accessToken = response.data['data']['accessToken'];
    final refreshToken = response.data['data']['refreshToken'];
  } catch (e) {
    print('Error: $e');
  }
}

// Login
Future<void> login(String email, String password) async {
  try {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    // Save tokens
  } catch (e) {
    print('Error: $e');
  }
}
```

### Android Emulator/Physical Device

- **Android Emulator**: Sử dụng `http://10.0.2.2:3000` thay vì `localhost`
- **iOS Simulator**: Sử dụng `http://localhost:3000`
- **Physical Device**: Sử dụng IP máy tính của bạn: `http://YOUR_IP:3000`

### CORS Configuration

Server đã được cấu hình CORS để cho phép requests từ mobile apps.

---

## Environment Variables

Tạo file `.env` trong thư mục `eater-backend`:

```env
PORT=3000
MONGODB_URI=mongodb://127.0.0.1:27017/ai_healthy_meal_planner
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-key-change-in-production
NODE_ENV=development
```

---

## Error Response Format

Tất cả các lỗi đều trả về format chuẩn:

```json
{
  "status": "fail" | "error",
  "statusCode": 400,
  "message": "Error message here"
}
```

Validation errors:

```json
{
  "status": "fail",
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email must be a valid email address"
    }
  ]
}
```
