import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key});

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  int _countdown = 32;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 32));
    _progress = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _ctrl.forward();
    _startTimer();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) context.push('/tracking/on-the-way');
    });
  }

  void _startTimer() async {
    for (int i = 32; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _countdown = i);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
        title: const Text('Request Sent'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: WingaColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.headset_mic_outlined,
                    size: 14, color: WingaColors.textSecondary),
                const SizedBox(width: 4),
                Text('Help',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: WingaColors.textSecondary,
                    )),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Success icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: WingaColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: WingaColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 36),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Your request has been sent!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: WingaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "We're finding the best Winga near you.\nPlease stay online.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: WingaColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Finding progress card
            WingaCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: WingaColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_search_rounded,
                        color: WingaColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Finding a Winga...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WingaColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Searching nearby verified Wingas.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WingaColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progress.value * 0.4,
                            backgroundColor: WingaColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                WingaColors.primary),
                            borderRadius: BorderRadius.circular(100),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      Text(
                        '${_countdown}s',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.primary,
                        ),
                      ),
                      const Text(
                        'Estimated\ntime',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: WingaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Request details
            WingaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Request',
                          style: WingaTextStyles.headingSmall),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'View Details >',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WingaColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    iconColor: WingaColors.primary,
                    label: 'Meeting Point',
                    sub: 'Kariakoo, Dar es Salaam',
                    detail: 'Near Posta Street (TNM Shop)',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    iconColor: WingaColors.error,
                    label: 'Shopping Area',
                    sub: 'Kariakoo Market',
                    detail: 'I need help visiting 3–5 shops',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: WingaColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            size: 18, color: WingaColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary)),
                            Text('Electronics',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WingaColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.phone_android_rounded,
                            size: 20, color: WingaColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: WingaColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.schedule_outlined,
                            size: 18, color: WingaColors.gold),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service Type',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary)),
                            Text('Hourly (2 – 3 hours)',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Text(
                        'TZS 15,000',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Safety + share
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: WingaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined,
                        size: 16, color: WingaColors.gold),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Safety First!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(
                          'All Wingas are verified. You can share your trip with family and friends.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WingaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: WingaColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.share_outlined,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Share Trip',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // What's next
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("What's Next?",
                  style: WingaTextStyles.headingSmall),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                _NextStep(
                    icon: Icons.search_rounded,
                    label: 'Finding Winga',
                    sub: "We're looking for the best match",
                    isActive: true),
                _NextConnector(),
                _NextStep(
                    icon: Icons.check_rounded,
                    label: 'Winga Accepts',
                    sub: 'A Winga will accept your request'),
                _NextConnector(dashed: true),
                _NextStep(
                    icon: Icons.directions_car_outlined,
                    label: 'Winga On the Way',
                    sub: "You'll see Winga's live location"),
                _NextConnector(dashed: true),
                _NextStep(
                    icon: Icons.handshake_outlined,
                    label: 'Meet & Start',
                    sub: 'Meet your Winga and start shopping!'),
              ],
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WingaColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.headset_mic_outlined,
                        size: 20, color: WingaColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need help?',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                          Text('Our support team is available 24/7',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: WingaColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: WingaColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  final String detail;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: WingaColors.textSecondary)),
            Text(sub,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            Text(detail,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: WingaColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _NextStep extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool isActive;

  const _NextStep({
    required this.icon,
    required this.label,
    required this.sub,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? WingaColors.primary
                  : WingaColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 18,
                color: isActive
                    ? Colors.white
                    : WingaColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? WingaColors.primary
                  : WingaColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            sub,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 8,
              color: WingaColors.textLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _NextConnector extends StatelessWidget {
  final bool dashed;
  const _NextConnector({this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: dashed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (_) => Container(
                      width: 3, height: 1, color: WingaColors.border),
                ),
              )
            : Container(height: 2, color: WingaColors.primary),
      ),
    );
  }
}
