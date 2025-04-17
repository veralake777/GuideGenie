class ValidationHelper {
  // Validate required fields
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
  
  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
  
  // Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }
  
  // Validate minimum length
  static String? Function(String?) validateMinLength(int minLength) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'This field is required';
      }
      
      if (value.trim().length < minLength) {
        return 'Must be at least $minLength characters';
      }
      return null;
    };
  }
  
  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  // Validate matching passwords
  static String? validatePasswordMatch(String? value, String? match) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != match) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}