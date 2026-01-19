# AI Healthy Meal Planner

A Flutter mobile application for AI-powered healthy meal planning with personalized nutrition tracking.

## Architecture

This project follows **Clean Architecture** principles with three main layers:

### 1. Presentation Layer
- **Pages**: UI screens
- **Widgets**: Reusable UI components
- **Providers**: State management using Riverpod

### 2. Domain Layer
- **Entities**: Business objects
- **Repositories**: Abstract contracts
- **Use Cases**: Business logic

### 3. Data Layer
- **Models**: Data transfer objects
- **Data Sources**: Remote API and local storage
- **Repository Implementations**: Concrete implementations

## Project Structure

```
lib/
├── core/                          # Shared/common code
│   ├── constants/                 # App-wide constants
│   │   └── app_constants.dart
│   ├── di/                        # Dependency injection
│   │   └── providers.dart
│   ├── network/                   # Networking configuration
│   │   └── dio_client.dart
│   ├── routes/                    # App routing
│   │   └── app_routes.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   ├── utils/                     # Utility functions
│   │   ├── validators.dart
│   │   └── datetime_helper.dart
│   └── widgets/                   # Common widgets
│       └── common_widgets.dart
│
├── features/                      # Feature modules
│   ├── auth/                      # Authentication
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── register_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── profile/                   # User Profile & Health Info
│   ├── dietary_preferences/       # Dietary Preferences
│   ├── meal_plan/                 # AI Meal Planning (daily/weekly)
│   ├── recipes/                   # Recipe Browsing
│   ├── meal_logging/              # Meal Logging
│   ├── nutrition/                 # Nutrition Tracking
│   └── shopping_list/             # Shopping List
│
└── main.dart                      # App entry point
```

## Features

### 1. Authentication
- User login/register
- JWT token management
- Secure token storage

### 2. User Profile & Health Info
- Personal information management
- Health metrics tracking
- Activity level configuration

### 3. Dietary Preferences
- Diet type selection (vegan, keto, etc.)
- Food allergies and dislikes
- Cuisine preferences
- Calorie and macro targets

### 4. AI Meal Planning
- Daily meal plan generation
- Weekly meal plan generation
- AI-powered personalized recommendations
- Meal plan history

### 5. Recipe Browsing
- Browse recipe catalog
- Search recipes
- View recipe details
- Filter by tags and cuisine

### 6. Meal Logging
- Log meals with nutritional info
- Track meal times
- Add custom foods
- Photo logging

### 7. Nutrition Tracking
- Daily calorie tracking
- Macro nutrient tracking
- Micro nutrient monitoring
- Water intake tracking
- Nutrition history and trends

### 8. Shopping List
- Create shopping lists
- Auto-generate from meal plans
- Categorize items
- Mark items as purchased

## Tech Stack

### State Management
- **Riverpod 2.4.0**: Modern, compile-safe state management

### Networking
- **Dio 5.3.0**: HTTP client for API calls
- **Retrofit 4.0.0**: Type-safe REST client
- **Pretty Dio Logger**: Request/response logging

### Authentication & Security
- **Flutter Secure Storage**: Secure credential storage
- **JWT Decoder**: JWT token handling

### Local Storage
- **Shared Preferences**: Key-value storage
- **Hive**: NoSQL database

### Routing
- **Go Router 12.0.0**: Declarative routing

### Code Generation
- **Build Runner**: Code generation tool
- **Freezed**: Immutable data classes
- **Json Serializable**: JSON serialization
- **Riverpod Generator**: Riverpod code generation

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ai_healthy_meal_planner
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

## Development

### Code Generation
This project uses code generation for models, providers, and serialization. Run the following command after making changes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use watch mode during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Linting
The project uses `flutter_lints` for code quality. Run:
```bash
flutter analyze
```

### Testing
Run tests with:
```bash
flutter test
```

## API Configuration

Update the API base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

## Project Status

This is a **structural implementation** with placeholder files. The following needs to be implemented:

- [ ] UI implementation for all features
- [ ] API integration
- [ ] Business logic in use cases
- [ ] Repository implementations
- [ ] State management logic
- [ ] Unit and integration tests
- [ ] API documentation
- [ ] Error handling
- [ ] Loading states
- [ ] Form validation

## Contributing

1. Follow the Clean Architecture pattern
2. Keep features isolated and modular
3. Write tests for new features
4. Follow the existing code style
5. Use meaningful commit messages

## License

[Add your license here]