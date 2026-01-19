/// Utility class for validating user inputs.
class Validators {
  Validators._();

  /// Email validation regex pattern.
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  /// Password validation regex pattern (at least 8 chars, 1 uppercase, 1 lowercase, 1 number).
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  /// Validates password confirmation matches original.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates that a field is not empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates username format.
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Username must be less than 50 characters';
    }
    return null;
  }

  /// Validates phone number format.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates age is within reasonable range.
  static String? validateAge(int? value) {
    if (value == null) {
      return 'Age is required';
    }
    if (value < 13 || value > 120) {
      return 'Please enter a valid age (13-120)';
    }
    return null;
  }

  /// Validates weight is within reasonable range (in kg).
  static String? validateWeight(double? value) {
    if (value == null) {
      return 'Weight is required';
    }
    if (value < 20 || value > 500) {
      return 'Please enter a valid weight (20-500 kg)';
    }
    return null;
  }

  /// Validates height is within reasonable range (in cm).
  static String? validateHeight(double? value) {
    if (value == null) {
      return 'Height is required';
    }
    if (value < 50 || value > 300) {
      return 'Please enter a valid height (50-300 cm)';
    }
    return null;
  }
}
