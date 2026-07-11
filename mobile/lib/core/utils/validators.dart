class WingaValidators {
  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Enter a valid phone number';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? nida(String? v) {
    if (v == null || v.isEmpty) return 'National ID is required';
    if (v.replaceAll(RegExp(r'\D'), '').length < 14) return 'Enter a valid NIDA number';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? v, String password) {
    if (v != password) return 'Passwords do not match';
    return null;
  }
}
