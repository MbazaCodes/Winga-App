import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

final authRepositoryProvider = Provider((_) => AuthRepository());

// Current user state
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// OTP loading state
final otpLoadingProvider = StateProvider<bool>((ref) => false);

// Send OTP
final sendOtpProvider = FutureProvider.family<void, String>((ref, phone) async {
  await ref.read(authRepositoryProvider).sendOtp(phone);
});

// Verify OTP
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;
  final StateController<UserModel?> _userController;

  AuthNotifier(this._repo, this._userController)
      : super(const AsyncValue.data(null));

  Future<UserModel?> verifyOtp(String phone, String token) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.verifyOtp(phone, token);
      _userController.state = user;
      state = AsyncValue.data(user);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _userController.state = null;
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(currentUserProvider.notifier),
  );
});
