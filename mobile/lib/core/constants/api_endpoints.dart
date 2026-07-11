import 'app_constants.dart';

// ignore: constant_identifier_names
class ApiEndpoints {
  static const base = '${AppConstants.supabaseUrl}/rest/v1';

  // Auth
  static const signUp    = '/auth/v1/signup';
  static const signIn    = '/auth/v1/token?grant_type=password';
  static const otp       = '/auth/v1/otp';
  static const verifyOtp = '/auth/v1/verify';

  // Tables
  static const users        = '$base/users';
  static const wingas       = '$base/wingas';
  static const requests     = '$base/requests';
  static const transactions = '$base/transactions';
  static const reviews      = '$base/reviews';
  static const notifications = '$base/notifications';

  // Edge Functions
  static const approveWinga  = '${AppConstants.supabaseUrl}/functions/v1/approve-winga';
  static const initiatePayment = '${AppConstants.supabaseUrl}/functions/v1/initiate-payment';
  static const sendNotification = '${AppConstants.supabaseUrl}/functions/v1/send-notification';
}
