import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class WingaSession {
  static String? _uid;
  static UserType? _userType;

  static Future<void> setSession(String uid, UserType type) async {
    _uid = uid;
    _userType = type;
    final p = await SharedPreferences.getInstance();
    await p.setString(AppConstants.sessionKey, uid);
    await p.setString(AppConstants.userTypeKey, type.name);
  }

  static void setSessionUid(String uid) {
    _uid = uid;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.sessionKey, uid));
  }

  static void setUserType(UserType type) {
    _userType = type;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.userTypeKey, type.name));
  }

  static Future<void> setOnboarded() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.onboardedKey, true);
  }

  static Future<bool> isOnboarded() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(AppConstants.onboardedKey) ?? false;
  }

  static String? get uid => _uid;
  static String get safeUid => _uid ?? '';
  static UserType? get userType => _userType;
  static bool get isWinga => _userType == UserType.winga;
  static bool get isCustomer => _userType == UserType.customer;
  static bool get isLoggedIn => _uid != null && _uid!.isNotEmpty;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _uid = p.getString(AppConstants.sessionKey);
    final t = p.getString(AppConstants.userTypeKey);
    if (t != null) {
      _userType = UserType.values.firstWhere(
        (e) => e.name == t,
        orElse: () => UserType.customer,
      );
    }
  }

  static Future<void> clear() async {
    _uid = null;
    _userType = null;
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.remove(AppConstants.sessionKey),
      p.remove(AppConstants.userTypeKey),
    ]);
  }
}
