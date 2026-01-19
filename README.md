# AI Healthy Meal Planner

A production-ready Flutter mobile application for AI-powered healthy meal planning and nutrition tracking.

## 🌟 Features

- **Authentication**: Login, register, reset password with JWT-based authentication
- **User Profile & Health Information**: Manage personal details and health metrics
- **Dietary Preferences & Health Goals**: Set diet type, allergies, health goals
- **AI-Generated Meal Plans**: View daily and weekly AI-powered meal plans
- **Recipe Browsing**: Browse recipes with filtering and search
- **Meal Logging & Nutrition Tracking**: Log meals and track daily nutrition
- **Shopping List**: Generate shopping lists from meal plans

## 🏗️ Architecture

This project follows **Clean Architecture** principles with three main layers:

```
lib/
├── core/                    # Shared utilities and configurations
│   ├── constants/           # App-wide constants (API endpoints, app config)
│   ├── di/                  # Dependency injection setup
│   ├── errors/              # Error handling (exceptions, failures)
│   ├── extensions/          # Dart extensions
│   ├── network/             # Dio client, interceptors, network info
│   ├── router/              # App navigation with go_router
│   ├── theme/               # App theming
│   ├── utils/               # Utility classes (validators, use cases)
│   └── widgets/             # Shared widgets
│
├── features/                # Feature modules
│   ├── auth/                # Authentication feature
│   ├── user_profile/        # User profile & health info
│   ├── dietary_preferences/ # Dietary preferences & goals
│   ├── meal_plans/          # Meal planning (daily/weekly)
│   ├── recipes/             # Recipe browsing
│   ├── meal_logging/        # Meal logging & nutrition tracking
│   └── shopping_list/       # Shopping list management
│
├── app.dart                 # Main app widget
└── main.dart                # App entry point
```

### Feature Module Structure

Each feature follows a consistent structure:

```
feature/
├── data/
│   ├── datasources/         # Remote and local data sources
│   ├── models/              # Data models (JSON serialization)
│   └── repositories/        # Repository implementations
│
├── domain/
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Business logic use cases
│
└── presentation/
    ├── pages/               # Screen/page widgets
    ├── providers/           # Riverpod state management
    └── widgets/             # Feature-specific widgets
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Networking | Dio |
| Navigation | go_router |
| Dependency Injection | GetIt + Injectable |
| Authentication | JWT (jwt_decoder) |
| Local Storage | shared_preferences, flutter_secure_storage |
| Functional Programming | dartz (Either pattern) |
| Code Generation | freezed, json_serializable, retrofit |

## 📦 Dependencies

### Main Dependencies
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `go_router` - Navigation
- `get_it` & `injectable` - Dependency injection
- `dartz` - Functional programming utilities
- `freezed_annotation` - Immutable data classes
- `json_annotation` - JSON serialization
- `shared_preferences` - Key-value storage
- `flutter_secure_storage` - Secure token storage
- `jwt_decoder` - JWT token handling
- `connectivity_plus` - Network connectivity checking
- `cached_network_image` - Image caching

### Dev Dependencies
- `build_runner` - Code generation
- `freezed` - Immutable class generation
- `json_serializable` - JSON serialization code gen
- `retrofit_generator` - API client generation
- `mockito` & `mocktail` - Testing mocks

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/longntce182041/Eater-app.git
cd Eater-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## 📁 Project Structure

```
Eater-app/
├── assets/
│   ├── fonts/               # Custom fonts
│   ├── icons/               # App icons (SVG)
│   └── images/              # App images
│
├── lib/
│   ├── core/                # Core utilities
│   ├── features/            # Feature modules
│   ├── app.dart             # App widget
│   └── main.dart            # Entry point
│
├── test/
│   ├── core/                # Core unit tests
│   └── features/            # Feature tests
│
├── pubspec.yaml             # Dependencies
└── README.md                # This file
```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 📝 Development Guidelines

### Adding a New Feature

1. Create the feature folder under `lib/features/`
2. Create the three layers: `data/`, `domain/`, `presentation/`
3. Define entities in `domain/entities/`
4. Define repository interface in `domain/repositories/`
5. Create use cases in `domain/usecases/`
6. Implement data models in `data/models/`
7. Implement data sources in `data/datasources/`
8. Implement repository in `data/repositories/`
9. Create providers in `presentation/providers/`
10. Create pages and widgets in `presentation/`

### Code Generation

After modifying files with `@freezed`, `@JsonSerializable`, or other annotations:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of a graduation project.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- Clean Architecture principles by Robert C. Martin