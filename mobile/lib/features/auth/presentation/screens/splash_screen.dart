import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.primary,
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
      ),
    );
  }
}
