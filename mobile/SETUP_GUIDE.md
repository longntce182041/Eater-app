# Eater Mobile App - Setup Guide

This is a Flutter mobile application for the AI Healthy Meal Planner "Eater" system.

## Prerequisites

- Flutter SDK (v3.10.4 or higher)
- Dart SDK (v3.10.4 or higher)
- Android SDK (for Android development) or Xcode (for iOS development)
- Backend API server running on `http://localhost:3000` (for development)

## Installation

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Configure API Base URL

The app is currently configured to connect to `http://localhost:3000` for local development.

For Android emulator: Uses `http://10.0.2.2:3000`
For iOS simulator: Uses `http://localhost:3000`
For physical devices: Update the URL in [lib/src/config/env/env_loader.dart](lib/src/config/env/env_loader.dart)

### 3. Run the App

#### For Android:

```bash
flutter run
```

#### For iOS:

```bash
flutter run -d iPhone
```

#### For Web (if configured):

```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── src/
│   ├── config/              # App configuration
│   │   ├── env/            # Environment & API config
│   │   ├── router/         # Navigation routing
│   │   ├── theme/          # App theming
│   │   └── localization/   # Internationalization
│   ├── core/               # Core utilities
│   │   └── error/          # Error handling
│   ├── shared/             # Shared providers & services
│   │   ├── models/         # Shared data models
│   │   ├── providers/      # Riverpod providers
│   │   └── services/       # Shared services
│   └── features/           # Feature modules
│       ├── auth/           # Authentication feature
│       │   ├── data/       # Data layer
│       │   ├── domain/     # Domain layer
│       │   └── presentation/
│       ├── profile/        # User profile feature
│       │   ├── data/       # API & repository
│       │   └── presentation/
│       └── home/           # Home feature
├── main.dart               # App entry point
├── app.dart                # App widget
└── bootstrap.dart          # App initialization
```

## Features

### Authentication

- Sign up / Sign in
- Password reset
- Email verification
- JWT token management

### Profile Management

- Create/Edit user profile
- Manage health information
  - Age, gender, height, weight
  - Activity level
  - Daily calorie target
- Dietary preferences
- Allergies
- Cooking skill level

### Home

- Dashboard with quick actions
- Meal planning interface
- Recipe browsing
- Navigation between sections

## Development

### Running in Development Mode

```bash
flutter run
```

### Building for Release

#### Android:

```bash
flutter build apk
# or for release
flutter build apk --release
```

#### iOS:

```bash
flutter build ios
```

### Running Tests

```bash
flutter test
```

## API Integration

The app communicates with the backend API at `http://localhost:3000` (or your configured URL).

### Key Endpoints Used

- **Auth**: `/api/auth/login`, `/api/auth/register`, `/api/auth/logout`
- **Profile**: `/api/profile` (GET, POST, PUT)

### Authentication

The app uses JWT tokens stored in secure storage for authentication. Tokens are automatically added to all API requests via the Dio interceptor.

## Troubleshooting

### Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Platform-Specific Issues

For Android, if you encounter gradle issues:

```bash
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

For iOS:

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
flutter run
```

## Dependencies

Key dependencies:

- **flutter_riverpod**: State management
- **dio**: HTTP client
- **go_router**: Navigation
- **flutter_secure_storage**: Secure token storage
- **dartz**: Functional programming patterns

See [pubspec.yaml](pubspec.yaml) for complete list.

## Backend Integration

Ensure your backend API server is running before launching the app.

The backend should:

1. Be accessible at `http://localhost:3000` (local dev)
2. Have CORS configured to accept requests from the app
3. Implement the profile endpoints:
   - `GET /api/profile` - Get user profile
   - `POST /api/profile` - Create profile
   - `PUT /api/profile` - Update profile

## Contact & Support

For issues related to the mobile app, please refer to the project documentation or contact the development team.
