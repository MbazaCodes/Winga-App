import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class WingaOnTheWayScreen extends StatelessWidget {
  const WingaOnTheWayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Winga On The Way'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.headset_mic_outlined,
                    size: 14, color: WingaColors.primary),
                const SizedBox(width: 4),
                Text('Help',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status pill
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: WingaColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Winga Accepted',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: WingaColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.directions_car_outlined,
                            color: WingaColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Great news! Ahmed Juma is on the way.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: WingaColors.primary,
                                ),
                              ),
                              Text(
                                "You'll be notified when they arrive.",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: WingaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Map placeholder
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0E4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Map background
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: const Color(0xFFE8EDE9),
                            child: GridView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8),
                              itemBuilder: (_, __) => Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Route line
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RoutePainter(),
                          ),
                        ),
                        // ETA badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: WingaColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: WingaShadows.elevated,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Arriving in',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: WingaColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '6 min',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: WingaColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // GPS button
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: WingaColors.white,
                              shape: BoxShape.circle,
                              boxShadow: WingaShadows.card,
                            ),
                            child: const Icon(Icons.my_location_rounded,
                                size: 18, color: WingaColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Winga info
                  WingaCard(
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: WingaColors.primarySurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: WingaColors.primary, width: 2),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 34, color: WingaColors.primary),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: WingaColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.check,
                                    size: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    'Ahmed Juma',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded,
                                      size: 16,
                                      color: WingaColors.primary),
                                ],
                              ),
                              const RatingStars(rating: 4.9, count: 250),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: WingaColors.primarySurface,
                                  borderRadius:
                                      BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Electronics Expert',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: WingaColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _ActionBtn(
                              icon: Icons.phone_outlined,
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _ActionBtn(
                              icon: Icons.message_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trip details
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Trip Details',
                        style: WingaTextStyles.headingSmall),
                  ),
                  const SizedBox(height: 12),
                  WingaCard(
                    child: Column(
                      children: [
                        _TripDetailRow(
                          icon: Icons.location_on_rounded,
                          iconColor: WingaColors.primary,
                          label: 'Meeting Point',
                          value: 'Kariakoo, Dar es Salaam',
                          sub: 'Near Posta Street (TNM Shop)',
                          action: 'View on Map',
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          width: 1,
                          height: 20,
                          color: WingaColors.border,
                        ),
                        _TripDetailRow(
                          icon: Icons.location_on_rounded,
                          iconColor: WingaColors.error,
                          label: 'Shopping Area',
                          value: 'Kariakoo Market',
                          sub: 'Visiting 3 – 5 shops',
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 18),
                          width: 1,
                          height: 20,
                          color: WingaColors.border,
                        ),
                        _TripDetailRow(
                          icon: Icons.schedule_outlined,
                          iconColor: WingaColors.gold,
                          label: 'Service Type',
                          value: 'Hourly (2 – 3 hours)',
                          priceLabel: 'TZS 15,000',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ETA card
                  WingaCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: WingaColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.schedule_outlined,
                              color: WingaColors.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estimated Arrival',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary,
                                  )),
                              Text(
                                '6 min',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: WingaColors.textPrimary,
                                ),
                              ),
                              Text(
                                "We'll notify you when your Winga arrives.",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: WingaColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.directions_car_outlined,
                            size: 40, color: WingaColors.primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  SafetyBanner(
                    message:
                        'Your safety is our priority\nAll Wingas are verified and background-checked.',
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: WingaColors.white,
              border: const Border(
                  top: BorderSide(color: WingaColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: WingaButton(
                      label: 'Cancel Request',
                      variant: WingaButtonVariant.outlined,
                      height: 50,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WingaButton(
                      label: 'Contact Winga',
                      height: 50,
                      onPressed: () => context.push('/tracking/shopping'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: WingaColors.border),
        ),
        child: Icon(icon, size: 18, color: WingaColors.textPrimary),
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? sub;
  final String? priceLabel;
  final String? action;

  const _TripDetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.sub,
    this.priceLabel,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WingaColors.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (sub != null)
                  Text(sub!,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: WingaColors.textSecondary)),
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: WingaColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(action!,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: WingaColors.primary)),
              ),
            ),
          if (priceLabel != null)
            Text(priceLabel!,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WingaColors.primary)),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WingaColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.3,
      size.height * 0.7,
    );

    // Dashed path
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + 8),
          Offset.zero,
        );
        distance += 14;
      }
    }

    canvas.drawPath(dashPath, paint);

    // Pin at start
    final pinPaint = Paint()..color = WingaColors.primary;
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.2), 8, pinPaint);

    // Customer pin at end
    final custPaint = Paint()..color = WingaColors.error;
    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.7), 8, custPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
