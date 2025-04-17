/// A utility class for form validation
class ValidationHelper {
  /// Validates that a field is not empty
  static String? validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates that a string is a valid URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    // Simple URL validation regex
    final urlRegExp = RegExp(
      r'^(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?$',
      caseSensitive: false,
    );
    
    if (!urlRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid URL (e.g., https://example.com/image.jpg)';
    }
    
    return null;
  }

  /// Validates that a string is a valid email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Email validation regex
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates that a string meets password requirements
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  /// Validates that a string matches the given password
  static String? validatePasswordMatch(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates that a number is within a specific range
  static String? validateNumberRange(String? value, {int min = 0, int max = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number < min) {
      return 'Value must be at least $min';
    }
    
    if (number > max) {
      return 'Value must be no more than $max';
    }
    
    return null;
  }
}