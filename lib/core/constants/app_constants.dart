/// Application-wide constants and configuration values.
class AppConstants {
  AppConstants._();

  /// Application name
  static const String appName = 'AI Healthy Meal Planner';

  /// App version
  static const String appVersion = '1.0.0';

  /// Default timeout duration for API requests (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  /// Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';

  /// Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';

  /// Validation constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;

  /// Nutrition tracking
  static const int defaultDailyCalories = 2000;
  static const int defaultProteinGrams = 50;
  static const int defaultCarbsGrams = 250;
  static const int defaultFatGrams = 65;
}
