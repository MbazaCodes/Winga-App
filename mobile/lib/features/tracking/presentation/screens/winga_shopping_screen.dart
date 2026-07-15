import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class WingaShoppingScreen extends StatelessWidget {
  const WingaShoppingScreen({super.key});

  static const _steps = [
    _Step('Searching', true, true),
    _Step('Shopping', true, false),
    _Step('Reviewing', false, false),
    _Step('Delivery', false, false),
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
        title: const Text('Winga is Shopping'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.headset_mic_outlined, size: 14, color: WingaColors.primary),
                const SizedBox(width: 4),
                Text('Help', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: WingaColors.primary)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: WingaColors.inProgressLight,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: WingaColors.inProgress.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: WingaColors.inProgress, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('In Progress — Shopping Now',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: WingaColors.inProgress)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress stepper
            WingaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Live Progress', style: WingaTextStyles.headingSmall),
                      Text('Step 2 of 4', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: _steps.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      return Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: s.done
                                          ? WingaColors.primary
                                          : s.active
                                              ? WingaColors.inProgress
                                              : WingaColors.borderLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      s.done ? Icons.check_rounded : s.active ? Icons.shopping_bag_outlined : Icons.circle_outlined,
                                      size: 16,
                                      color: (s.done || s.active) ? Colors.white : WingaColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(s.label,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: (s.done || s.active) ? FontWeight.w600 : FontWeight.w400,
                                        color: s.done ? WingaColors.primary : s.active ? WingaColors.inProgress : WingaColors.textLight,
                                      ),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                            if (i < _steps.length - 1)
                              Container(
                                width: 20,
                                height: 2,
                                color: e.value.done ? WingaColors.primary : WingaColors.borderLight,
                                margin: const EdgeInsets.only(bottom: 18),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Live shop location
            WingaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.storefront_outlined, color: WingaColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Location', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                            Text('Shop 2 of 4 — Electronics Zone', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('Kariakoo Market, Block C', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: WingaColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.map_outlined, size: 18, color: WingaColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Map mini
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDE9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            color: const Color(0xFFE8F0E4),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                              itemBuilder: (_, __) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.3))),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: WingaColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Winga card
            WingaCard(
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: WingaColors.primarySurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: WingaColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, size: 32, color: WingaColors.primary),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: WingaColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check, size: 9, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Text('Ahmed Juma', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 15, color: WingaColors.primary),
                        ]),
                        const RatingStars(rating: 4.9, count: 250, size: 13),
                        const SizedBox(height: 3),
                        const Text('Electronics Expert', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.textSecondary)),
                      ],
                    ),
                  ),
                  Row(children: [
                    _CircleBtn(icon: Icons.phone_outlined, onTap: () {}),
                    const SizedBox(width: 8),
                    _CircleBtn(icon: Icons.message_outlined, onTap: () {}),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Shopping list
            const Text('Shopping List', style: WingaTextStyles.headingSmall),
            const SizedBox(height: 12),
            WingaCard(
              child: Column(
                children: [
                  _ShopItem(name: 'iPhone 15 Pro', shop: 'Tech World', status: 'Found ✓', done: true),
                  const Divider(height: 1, color: WingaColors.borderLight),
                  _ShopItem(name: 'Phone Case', shop: 'Accessories Hub', status: 'Searching...', done: false),
                  const Divider(height: 1, color: WingaColors.borderLight),
                  _ShopItem(name: 'Screen Protector', shop: 'TBD', status: 'Pending', done: false),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Notifications
            WingaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Live Updates', style: WingaTextStyles.headingSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: WingaColors.errorLight, borderRadius: BorderRadius.circular(100)),
                        child: const Text('3 new', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: WingaColors.error)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _UpdateItem(msg: 'Ahmed found iPhone 15 Pro at TZS 2,100,000', time: '2 min ago', icon: Icons.check_circle_rounded, color: WingaColors.success),
                  _UpdateItem(msg: 'Ahmed is now at Shop 2 of 4', time: '5 min ago', icon: Icons.storefront_outlined, color: WingaColors.inProgress),
                  _UpdateItem(msg: 'Shopping started for Electronics', time: '12 min ago', icon: Icons.shopping_bag_outlined, color: WingaColors.gold),
                ],
              ),
            ),
            const SizedBox(height: 20),

            WingaButton(
              label: 'View Full Details',
              variant: WingaButtonVariant.outlined,
              onPressed: () => context.push('/payment/final'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final String label;
  final bool done, active;
  const _Step(this.label, this.done, this.active);
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WingaColors.border)),
        child: Icon(icon, size: 17, color: WingaColors.textPrimary),
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String name, shop, status;
  final bool done;
  const _ShopItem({required this.name, required this.shop, required this.status, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 20, color: done ? WingaColors.success : WingaColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, decoration: done ? TextDecoration.lineThrough : null)),
                Text(shop, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: done ? WingaColors.successLight : WingaColors.borderLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(status,
                style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
                    color: done ? WingaColors.successText : WingaColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _UpdateItem extends StatelessWidget {
  final String msg, time;
  final IconData icon;
  final Color color;
  const _UpdateItem({required this.msg, required this.time, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textPrimary)),
                Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
