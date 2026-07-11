import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class WingaSession {
  static String? _uid;
  static UserType? _userType;

  static void setSessionUid(String uid) {
    _uid = uid;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.sessionKey, uid));
  }

  static String? get uid => _uid;

  static void setUserType(UserType type) {
    _userType = type;
    SharedPreferences.getInstance().then((p) => p.setString(AppConstants.userTypeKey, type.name));
  }

  static UserType? get userType => _userType;
  static bool get isWinga => _userType == UserType.winga;
  static bool get isCustomer => _userType == UserType.customer;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _uid = p.getString(AppConstants.sessionKey);
    final t = p.getString(AppConstants.userTypeKey);
    _userType = t != null
        ? UserType.values.firstWhere((e) => e.name == t, orElse: () => UserType.customer)
        : null;
  }

  static Future<void> clear() async {
    _uid = null;
    _userType = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(AppConstants.sessionKey);
    await p.remove(AppConstants.userTypeKey);
  }

  static bool get isLoggedIn => _uid != null;
}
