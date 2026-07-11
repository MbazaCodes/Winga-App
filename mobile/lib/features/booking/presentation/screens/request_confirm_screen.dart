import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class RequestConfirmScreen extends StatefulWidget {
  const RequestConfirmScreen({super.key});

  @override
  State<RequestConfirmScreen> createState() => _RequestConfirmScreenState();
}

class _RequestConfirmScreenState extends State<RequestConfirmScreen> {
  int _selectedType = 0; // 0=Hourly, 1=Half Day, 2=Full Day, 3=Custom
  bool _isLoading = false;

  static const _types = [
    _ServiceType('Hourly', '(Popular)', '2 – 3 hours', 15000, true),
    _ServiceType('Half Day', '', '4 – 5 hours', 25000, false),
    _ServiceType('Full Day', '', '6 – 8 hours', 40000, false),
    _ServiceType('Custom', '', 'Set your own time', 0, false),
  ];

  @override
  Widget build(BuildContext context) {
    final type = _types[_selectedType];

    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Request Winga'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined,
                    size: 14, color: WingaColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Safe & Secure',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WingaColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: WingaStepIndicator(
              totalSteps: 6,
              currentStep: 5,
              labels: const [
                'Choose\nService',
                'Details',
                'Preferences',
                'Find Winga',
                'Request',
                'Confirm',
              ],
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
                      "You're almost there!",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: WingaColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Review your request and confirm to find a Winga near you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: WingaColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Meeting + Shopping area card
                  WingaCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LocationRow(
                                color: WingaColors.primary,
                                label: 'Meeting Point',
                                location: 'Kariakoo, Dar es Salaam',
                                sublocation: 'Near Posta Street (TNM Shop)',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: Container(
                                    width: 1,
                                    height: 20,
                                    color: WingaColors.border),
                              ),
                              _LocationRow(
                                color: WingaColors.error,
                                label: 'Shopping Area',
                                location: 'Kariakoo Market',
                                sublocation: 'I need help visiting 3–5 shops',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: WingaColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.map_outlined,
                                  color: WingaColors.primary, size: 32),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Change Location ⊕',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: WingaColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferences
                  const Text('Selected Preferences',
                      style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  WingaCard(
                    child: Column(
                      children: [
                        _PrefRow(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Category',
                            value: 'Electronics'),
                        const Divider(height: 1),
                        _PrefRow(
                            icon: Icons.track_changes_rounded,
                            label: 'Goal',
                            value: 'Best Price & Original'),
                        const Divider(height: 1),
                        _PrefRow(
                            icon: Icons.storefront_outlined,
                            label: 'Number of Shops',
                            value: '3 – 5 shops'),
                        const Divider(height: 1),
                        _PrefRow(
                            icon: Icons.schedule_outlined,
                            label: 'Estimated Duration',
                            value: '2 – 3 hours'),
                        const Divider(height: 1),
                        _PrefRow(
                            icon: Icons.message_outlined,
                            label: 'Additional Note',
                            value: 'Looking for iPhone & accessories'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Choose Service Type',
                      style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),

                  // Service type selector
                  Row(
                    children: List.generate(
                      _types.length,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                          child: _ServiceTypeCard(
                            type: _types[i],
                            isSelected: _selectedType == i,
                            onTap: () => setState(() => _selectedType = i),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WingaColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield_outlined,
                            size: 16, color: WingaColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          'You can extend time later if needed.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WingaColors.goldDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment method
                  const Text('Payment Method',
                      style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  WingaCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: WingaColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              size: 20, color: WingaColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wallet Balance',
                                  style: WingaTextStyles.labelMedium),
                              Text('TZS 32,500',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: WingaColors.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: const [
                              Text('Change',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: WingaColors.primary,
                                  )),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18,
                                  color: WingaColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: WingaColors.white,
              border: const Border(
                  top: BorderSide(color: WingaColors.borderLight)),
              boxShadow: WingaShadows.card,
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Estimated Total',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: WingaColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: WingaColors.textLight),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TZS ${type.price == 0 ? 'Custom' : _fmt(type.price)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.primary,
                        ),
                      ),
                      Text(
                        '${type.duration} service',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: WingaColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        WingaButton(
                          label: 'Confirm Request',
                          trailing: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                          height: 50,
                          isLoading: _isLoading,
                          onPressed: () {
                            setState(() => _isLoading = true);
                            Future.delayed(const Duration(milliseconds: 600),
                                () {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                context.push('/book/delivery');
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.shield_outlined,
                                size: 12, color: WingaColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'No upfront payment. Pay after service.',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}

class _LocationRow extends StatelessWidget {
  final Color color;
  final String label;
  final String location;
  final String sublocation;

  const _LocationRow({
    required this.color,
    required this.label,
    required this.location,
    required this.sublocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
                Text(location,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: WingaColors.textPrimary)),
                Text(sublocation,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WingaColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PrefRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: WingaColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: WingaTextStyles.bodyMedium),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WingaColors.primary,
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: WingaColors.textLight),
        ],
      ),
    );
  }
}

class _ServiceType {
  final String name;
  final String tag;
  final String duration;
  final int price;
  final bool isPopular;
  const _ServiceType(
      this.name, this.tag, this.duration, this.price, this.isPopular);
}

class _ServiceTypeCard extends StatelessWidget {
  final _ServiceType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? WingaColors.primarySurface : WingaColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? WingaColors.primary : WingaColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: WingaColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 10, color: Colors.white),
                ),
              ),
            Icon(
              type.isPopular
                  ? Icons.access_time_rounded
                  : Icons.calendar_today_outlined,
              size: 22,
              color: isSelected ? WingaColors.primary : WingaColors.textLight,
            ),
            const SizedBox(height: 6),
            Text(
              type.name,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? WingaColors.primary
                    : WingaColors.textPrimary,
              ),
            ),
            if (type.tag.isNotEmpty)
              Text(
                type.tag,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: WingaColors.textSecondary,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              type.duration,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: WingaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              type.price == 0
                  ? 'Custom\nprice'
                  : 'TZS ${_fmt(type.price)}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? WingaColors.primary : WingaColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
