import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../domain/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/session.dart';

class AuthRepository {
  final _client = Supabase.instance.client;

  /// Phone OTP — request code
  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: '+255$phone');
  }

  /// Verify OTP — returns user model on success
  Future<UserModel?> verifyOtp(String phone, String token) async {
    final res = await _client.auth.verifyOTP(
      phone: '+255$phone',
      token: token,
      type: OtpType.sms,
    );

    final userId = res.session?.user.id;
    if (userId == null) return null;

    // Fetch user record from our users table
    final rows = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (rows == null) return null;
    final user = UserModel.fromJson(rows as Map<String, dynamic>);
    WingaSession.setSessionUid(userId);
    WingaSession.setUserType(
      user.userType == 'winga' ? UserType.winga : UserType.customer,
    );
    return user;
  }

  /// Bypass auth — direct users table insert (dev only)
  Future<UserModel?> bypassLogin(String phone, String password) async {
    final encoded = base64.encode(utf8.encode(password));
    final rows = await _client
        .from('user_credentials')
        .select('user_id')
        .eq('phone', phone)
        .eq('password_hash', encoded)
        .maybeSingle();

    if (rows == null) return null;
    final uid = rows['user_id'] as String;

    final userRow = await _client
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (userRow == null) return null;

    final user = UserModel.fromJson(userRow as Map<String, dynamic>);
    WingaSession.setSessionUid(uid);
    WingaSession.setUserType(
      user.userType == 'winga' ? UserType.winga : UserType.customer,
    );
    return user;
  }

  /// Register new customer
  Future<UserModel?> registerCustomer({
    required String phone,
    required String name,
    String? email,
  }) async {
    // Insert into users table directly
    final row = await _client.from('users').insert({
      'phone': '+255$phone',
      'name': name,
      'email': email,
      'user_type': 'customer',
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return UserModel.fromJson(row as Map<String, dynamic>);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    await WingaSession.clear();
  }
}
