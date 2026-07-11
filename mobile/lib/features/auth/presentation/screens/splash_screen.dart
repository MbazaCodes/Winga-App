import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6)),
    );
    _scale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                // Logo container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: WingaColors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: _WingaLogoIcon(size: 60),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'WINGA',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: WingaColors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'APP',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: WingaColors.gold,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      WingaColors.white.withOpacity(0.5),
                    ),
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

class _WingaLogoIcon extends StatelessWidget {
  final double size;
  const _WingaLogoIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WingaLogoPainter()),
    );
  }
}

class _WingaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final goldPaint = Paint()..color = WingaColors.gold;

    // Draw W/pin shape simplified
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;

    // Pin shape
    path.addOval(Rect.fromCircle(center: Offset(cx, cy - r * 0.2), radius: r));
    path.moveTo(cx, cy + r * 0.8);
    path.lineTo(cx - r * 0.3, cy + r * 0.3);
    path.lineTo(cx + r * 0.3, cy + r * 0.3);
    path.close();

    canvas.drawPath(path, whitePaint);

    // Person icon inside
    final personPaint = Paint()..color = WingaColors.gold;
    canvas.drawCircle(Offset(cx, cy - r * 0.4), r * 0.22, personPaint);

    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(
      center: Offset(cx, cy + r * 0.0),
      width: r * 0.5,
      height: r * 0.35,
    ));
    canvas.drawPath(bodyPath, personPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
