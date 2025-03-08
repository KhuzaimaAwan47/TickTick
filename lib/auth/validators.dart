// validators
import 'database_helper.dart';

class Validators {

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  static String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }



  static Future<String?> validateUserNameForSignUp(String? value) async {
    final basicValidation = validateUserName(value);
    if (basicValidation != null) return basicValidation;

    // Query the database for the given username.
    final user = await DatabaseHelper().getUser(value!);
    if (user != null) {
      return 'Username already exists';
    }
    return null;
  }

  static Future<String?> validateUserNameForLogin(String? value) async {
    final basicValidation = validateUserName(value);
    if (basicValidation != null) return basicValidation;

    final user = await DatabaseHelper().getUser(value!);
    if (user == null) {
      return 'Username is incorrect';
    }
    return null;
  }

  static Future<String?> validatePasswordForLogin(String username, String? value) async {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;

    final user = await DatabaseHelper().getUser(username);
    if (user != null && user.password != value) {
      return 'Password is incorrect';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}