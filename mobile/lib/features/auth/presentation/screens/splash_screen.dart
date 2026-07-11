import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final uid      = prefs.getString(AppConstants.sessionKey);
    final userType = prefs.getString(AppConstants.userTypeKey);
    final onboarded = prefs.getBool(AppConstants.onboardedKey) ?? false;

    if (!mounted) return;

    if (uid != null && uid.isNotEmpty) {
      // Logged in — go to correct home
      if (userType == 'winga') {
        context.go('/winga-home');
      } else {
        context.go('/home');
      }
    } else if (!onboarded) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: WingaColors.white.withOpacity(0.15),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('WINGA', style: TextStyle(fontFamily: 'Inter',
                    fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('APP', style: TextStyle(fontFamily: 'Inter',
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: WingaColors.gold, letterSpacing: 6)),
                const SizedBox(height: 48),
                SizedBox(width: 32, height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.5)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
