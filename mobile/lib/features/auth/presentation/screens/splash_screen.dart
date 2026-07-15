import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _logoScale = 0.3;
  double _logoOpacity = 0.0;
  double _textOpacity = 0.0;
  bool _showTagline = false;
  String? _error;
=======
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _logoScale = 1.0;
      _logoOpacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _textOpacity = 1.0);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _showTagline = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Add a timeout for navigation
    Future.delayed(const Duration(seconds: 10)).then((_) {
      if (mounted && _error == null) {
        setState(() => _error = "Inachukua muda mrefu... tafadhali subiri.");
      }
    });

    _navigate();
  }

  Future<void> _navigate() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final user = await Supabase.instance.client
            .from('users')
            .select('user_type')
            .eq('id', session.user.id)
            .maybeSingle();

        final type = user?['user_type'] == 'winga' ? 'winga' : 'customer';
        if (mounted) {
          context.go(type == 'winga' ? '/winga/home' : '/home');
          return;
        }
      }
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      // If we are here, something went wrong with Supabase but we still want to move forward if possible
    }

    if (!mounted) return;

    try {
      final onboarded = await WingaSession.isOnboarded();
      if (onboarded) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      debugPrint('Fallback navigation error: $e');
      if (mounted) {
        context.go('/onboarding');
      }
    }
=======
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.primary,
<<<<<<< HEAD
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemBuilder: (_, __) => Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                AnimatedScale(
                  scale: _logoScale,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  child: AnimatedOpacity(
                    opacity: _logoOpacity,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: const Center(
                        child: Text('📍', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text
                AnimatedOpacity(
                  opacity: _textOpacity,
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      const Text(
                        'WINGA',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const Text(
                        'APP',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WingaColors.gold,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        opacity: _showTagline ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Mwongozo Wako wa Ununuzi Tanzania',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 20),
                  Text(_error!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _navigate(),
                    child: const Text('Jaribu Tena', style: TextStyle(color: WingaColors.gold)),
                  )
                ]
              ],
            ),
          ),

          // Loader
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: WingaColors.gold,
                ),
              ),
            ),
          ),
        ],
=======
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
      ),
    );
  }
}
