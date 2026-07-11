import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/session.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1000));
    _fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _navigate() async {
    // Minimum splash time for branding
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // 1. Check Supabase active session first (most reliable)
    final supaSession = Supabase.instance.client.auth.currentSession;
    if (supaSession != null) {
      final uid = supaSession.user.id;
      // Get user type from our table
      final row = await Supabase.instance.client
          .from('users')
          .select('user_type')
          .eq('id', uid)
          .maybeSingle();

      if (!mounted) return;
      final userType = row?['user_type'] as String? ?? 'customer';
      WingaSession.setSessionUid(uid);
      WingaSession.setUserType(
          userType == 'winga' ? UserType.winga : UserType.customer);

      if (userType == 'winga') {
        context.go('/winga-home');
      } else {
        context.go('/home');
      }
      return;
    }

    // 2. Fall back to SharedPreferences session (offline / faster re-open)
    if (WingaSession.isLoggedIn) {
      if (!mounted) return;
      context.go(WingaSession.isWinga ? '/winga-home' : '/home');
      return;
    }

    // 3. First time — check onboarded flag
    if (!mounted) return;

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.location_on_rounded,
                        size: 56, color: Colors.white),
                    Positioned(
                      top: 18,
                      child: const Icon(Icons.person_rounded,
                          size: 26, color: WingaColors.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('WINGA',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 38,
                      fontWeight: FontWeight.w800, color: Colors.white,
                      letterSpacing: 5)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 28, height: 1, color: WingaColors.gold),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('APP', style: TextStyle(fontFamily: 'Inter',
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: WingaColors.gold, letterSpacing: 5)),
                    ),
                    Container(width: 28, height: 1, color: WingaColors.gold),
                  ],
                ),
                const SizedBox(height: 52),
                SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
