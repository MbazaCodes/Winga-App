import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class DeliveryMethodScreen extends StatefulWidget {
  const DeliveryMethodScreen({super.key});
  @override
  State<DeliveryMethodScreen> createState() => _DeliveryMethodScreenState();
}

class _DeliveryMethodScreenState extends State<DeliveryMethodScreen> {
  int _selected = 0;

  static const _methods = [
    _Method(
      icon: Icons.person_rounded,
      emoji: '🛍️',
      title: 'Shop with Client',
      subtitle: 'Meet the Winga and shop together',
      desc: 'Winga will meet you at the location and assist you shop in person.',
      badge: 'Most Popular',
      badgeColor: WingaColors.primary,
      extras: ['No delivery fee', 'Real-time negotiation', 'Personal experience'],
    ),
    _Method(
      icon: Icons.local_shipping_rounded,
      emoji: '🚗',
      title: 'Shop then Deliver',
      subtitle: 'Winga shops and delivers to you',
      desc: 'Winga will shop for you and deliver items to your specified address.',
      badge: 'Delivery Fee Applies',
      badgeColor: WingaColors.inProgress,
      extras: ['Delivery fee: TZS 2,000', 'Convenient for busy people', 'Safe packaging'],
    ),
    _Method(
      icon: Icons.store_rounded,
      emoji: '📦',
      title: 'Shop then Pickup',
      subtitle: 'Pick up from a nearby point',
      desc: 'Winga shops and brings items to a nearby pickup point you choose.',
      badge: 'Reduced Fee',
      badgeColor: Color(0xFF6A1B9A),
      extras: ['Pickup fee: TZS 1,000', 'Flexible timing', 'Multiple pickup points'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Delivery Method'),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: WingaStepIndicator(
              totalSteps: 6,
              currentStep: 6,
              labels: const ['Choose\nService', 'Details', 'Preferences', 'Find Winga', 'Request', 'Confirm'],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'How should Winga\nhandle your request?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: WingaColors.primary, height: 1.2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Choose how you want to receive your items\nfrom the Winga.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ..._methods.asMap().entries.map((e) => _MethodCard(
                    method: e.value,
                    isSelected: _selected == e.key,
                    onTap: () => setState(() => _selected = e.key),
                  )),

                  const SizedBox(height: 14),
                  SafetyBanner(
                    message: 'All delivery methods are safe & insured\nYour items are protected throughout the process.',
                    onTap: () {},
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: WingaColors.white,
              border: const Border(top: BorderSide(color: WingaColors.borderLight)),
              boxShadow: WingaShadows.card,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                        child: Text(_methods[_selected].emoji, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_methods[_selected].title,
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(_methods[_selected].subtitle,
                                style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: WingaColors.primary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  WingaButton(
                    label: 'Confirm & Send Request →',
                    height: 52,
                    onPressed: () => context.push('/book/sent'),
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

class _Method {
  final IconData icon;
  final String emoji, title, subtitle, desc, badge;
  final Color badgeColor;
  final List<String> extras;
  const _Method({required this.icon, required this.emoji, required this.title, required this.subtitle, required this.desc, required this.badge, required this.badgeColor, required this.extras});
}

class _MethodCard extends StatelessWidget {
  final _Method method;
  final bool isSelected;
  final VoidCallback onTap;
  const _MethodCard({required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? WingaColors.primarySurface : WingaColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? WingaColors.primary : WingaColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: WingaShadows.card,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Emoji illustration
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isSelected ? WingaColors.white : WingaColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(method.emoji, style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: method.badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(method.badge,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: method.badgeColor)),
                      ),
                      const SizedBox(height: 6),
                      Text(method.title,
                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                              color: isSelected ? WingaColors.primary : WingaColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(method.subtitle,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? WingaColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? WingaColors.primary : WingaColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WingaColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(method.desc,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 10),
                    ...method.extras.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 15, color: WingaColors.primary),
                          const SizedBox(width: 8),
                          Text(e, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textPrimary)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
