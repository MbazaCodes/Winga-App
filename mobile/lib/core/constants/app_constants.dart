class AppConstants {
  // Supabase
  static const supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Pricing (TZS)
  static const priceHourly    = 15000;
  static const priceHalfDay   = 25000;
  static const priceFullDay   = 40000;

  // Commission
  static const platformCommissionRate = 0.20;  // 20%
  static const wingaPayoutRate        = 0.80;  // 80%
  static const taxRateMin             = 0.03;  // 3%
  static const taxRateMax             = 0.05;  // 5%

  // App
  static const appName      = 'Winga App';
  static const appVersion   = '1.0.0';
  static const supportEmail = 'support@winga.co.tz';
  static const supportPhone = '+255 800 000 000';

  // Maps
  static const defaultLat  = -6.7924;   // Dar es Salaam
  static const defaultLng  = 39.2083;
  static const defaultZoom = 14.0;

  // Session
  static const sessionKey   = 'winga_session_uid';
  static const userTypeKey  = 'winga_user_type';
  static const onboardedKey = 'winga_onboarded';
}

enum UserType { customer, winga, admin }
enum WingaBadge { bronze, silver, gold }
enum ServiceType { hourly, halfDay, fullDay, custom }
