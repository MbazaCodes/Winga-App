class AppConstants {
  // Supabase
  static const supabaseUrl = 'https://kevdbsyiqelksxvmuped.supabase.co';
  static const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtldmRic3lpcWVsa3N4dm11cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM3MzUyMjIsImV4cCI6MjA5OTMxMTIyMn0.pNmc5HGE9huxmh4-eqveLETkxnxJ_j5rigeS8t35o2A';

  // Pricing (TZS)
  static const priceHourly   = 15000;
  static const priceHalfDay  = 25000;
  static const priceFullDay  = 40000;

  // Commission
  static const platformCommissionRate = 0.20;
  static const wingaPayoutRate        = 0.80;
  static const taxRateMin             = 0.03;
  static const taxRateMax             = 0.05;

  // App
  static const appName      = 'Winga App';
  static const appVersion   = '1.0.0';
  static const supportEmail = 'support@winga.co.tz';
  static const supportPhone = '+255 800 000 000';

  // Maps
  static const defaultLat  = -6.7924;
  static const defaultLng  = 39.2083;
  static const defaultZoom = 14.0;

  // Session keys
  static const sessionKey   = 'winga_session_uid';
  static const userTypeKey  = 'winga_user_type';
  static const onboardedKey = 'winga_onboarded';
}

enum UserType { customer, winga, admin }
enum WingaBadge { bronze, silver, gold }
enum ServiceType { hourly, halfDay, fullDay, custom }
