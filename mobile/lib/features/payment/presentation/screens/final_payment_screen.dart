import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class FinalPaymentScreen extends StatefulWidget {
  /// Id of the request being paid for. Passed through to the rating screen so
  /// the customer's point is attached to the correct trip.
  final String requestId;

  const FinalPaymentScreen({super.key, this.requestId = ''});
  @override
  State<FinalPaymentScreen> createState() => _FinalPaymentScreenState();
}

class _FinalPaymentScreenState extends State<FinalPaymentScreen> {
  int _method = 0;
  bool _isLoading = false;

  static const _methods = [
    _PayMethod(Icons.account_balance_wallet_rounded, 'Winga Wallet', 'Balance: TZS 32,500', WingaColors.primary),
    _PayMethod(Icons.phone_android_rounded, 'Mobile Money', 'M-Pesa, Airtel, Tigo, HaloPesa', Color(0xFF1565C0)),
    _PayMethod(Icons.credit_card_rounded, 'Card Payment', 'Visa, Mastercard', Color(0xFF6A1B9A)),
    _PayMethod(Icons.account_balance_rounded, 'Bank Transfer', 'Direct bank payment', Color(0xFFF57F17)),
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
        title: const Text('Final Payment'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              Icon(Icons.shield_outlined, size: 13, color: WingaColors.primary),
              SizedBox(width: 4),
              Text('Secure', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: WingaColors.primary)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Winga served card
                  WingaCard(
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 56, height: 56,
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
                                width: 18, height: 18,
                                decoration: BoxDecoration(color: WingaColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: const Icon(Icons.check, size: 10, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Service Completed!', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: WingaColors.primary)),
                              SizedBox(height: 2),
                              Text('Ahmed Juma helped you with Electronics Shopping', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                              SizedBox(height: 6),
                              RatingStars(rating: 4.9, count: 250, size: 13),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: WingaColors.successLight, borderRadius: BorderRadius.circular(100)),
                          child: const Text('Verified', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: WingaColors.successText)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment breakdown
                  const Text('Payment Breakdown', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  WingaCard(
                    child: Column(
                      children: [
                        _BillRow(label: 'Service Fee (Hourly)', sub: '2 hours service', amount: 'TZS 15,000'),
                        const Divider(height: 16, color: WingaColors.borderLight),
                        _BillRow(label: 'Winga Convenience Fee', sub: '10% of service', amount: 'TZS 1,500'),
                        const Divider(height: 16, color: WingaColors.borderLight),
                        _BillRow(label: 'Delivery Fee', sub: 'Shop then Deliver method', amount: 'TZS 2,000'),
                        const Divider(height: 16, color: WingaColors.borderLight),
                        _BillRow(label: 'Tax (3%)', sub: 'Per TRA regulations', amount: '+ TZS 553', valueColor: WingaColors.error),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: WingaColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Amount', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textSecondary)),
                                  Text('TZS 19,053', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800, color: WingaColors.primary)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(Icons.lock_rounded, size: 18, color: WingaColors.primary),
                                  SizedBox(height: 3),
                                  Text('Secure Payment', style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: WingaColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment method
                  const Text('Payment Method', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),

                  ..._methods.asMap().entries.map((e) => _PayMethodCard(
                    method: e.value,
                    isSelected: _method == e.key,
                    onTap: () => setState(() => _method = e.key),
                  )),

                  // Mobile money sub-options
                  if (_method == 1) ...[
                    const SizedBox(height: 12),
                    WingaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Mobile Provider', style: WingaTextStyles.labelMedium),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _MobileProvider('M-Pesa', Colors.green),
                              const SizedBox(width: 8),
                              _MobileProvider('Airtel', Colors.red),
                              const SizedBox(width: 8),
                              _MobileProvider('Tigo', Colors.blue),
                              const SizedBox(width: 8),
                              _MobileProvider('HaloPesa', Colors.purple),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile money number',
                              prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: WingaColors.textLight),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: WingaColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: WingaColors.border)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Promo code
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: WingaColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WingaColors.border, style: BorderStyle.solid),
                      boxShadow: WingaShadows.card,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 18, color: WingaColors.gold),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Have a promo code?', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Add Code →', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: WingaColors.primary)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom pay button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: WingaColors.white,
              border: const Border(top: BorderSide(color: WingaColors.borderLight)),
              boxShadow: WingaShadows.elevated,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.lock_rounded, size: 14, color: WingaColors.textLight),
                      SizedBox(width: 5),
                      Text('256-bit encrypted & secure transaction', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.textLight)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  WingaButton(
                    label: 'Pay TZS 19,053 Now',
                    trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    isLoading: _isLoading,
                    height: 54,
                    onPressed: () {
                      setState(() => _isLoading = true);
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          _showSuccess(context);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: WingaColors.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 44, color: WingaColors.success),
            ),
            const SizedBox(height: 16),
            const Text('Payment Successful!', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: WingaColors.primary)),
            const SizedBox(height: 8),
            const Text('TZS 19,053 paid successfully.\nThank you for using Winga!', textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary)),
            const SizedBox(height: 24),
            WingaButton(
              label: 'Mpe Pointi Ahmed Juma ⭐',
              onPressed: () {
                Navigator.pop(ctx);
                // Hand off to the real rating screen so the point is actually
                // recorded. requestId comes from the active booking.
                ctx.go('/rate?request=${widget.requestId}&winga=Ahmed%20Juma');
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () { Navigator.pop(ctx); ctx.go('/home'); },
              child: const Text('Ruka', style: TextStyle(fontFamily: 'Inter', color: WingaColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayMethod {
  final IconData icon;
  final String title, sub;
  final Color color;
  const _PayMethod(this.icon, this.title, this.sub, this.color);
}

class _PayMethodCard extends StatelessWidget {
  final _PayMethod method;
  final bool isSelected;
  final VoidCallback onTap;
  const _PayMethodCard({required this.method, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? WingaColors.primarySurface : WingaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? WingaColors.primary : WingaColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: WingaShadows.card,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(method.icon, color: method.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(method.sub, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? WingaColors.primary : Colors.transparent,
                border: Border.all(color: isSelected ? WingaColors.primary : WingaColors.border, width: 2),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, sub, amount;
  final Color? valueColor;
  const _BillRow({required this.label, required this.sub, required this.amount, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500)),
              Text(sub, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.textSecondary)),
            ],
          ),
        ),
        Text(amount, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? WingaColors.textPrimary)),
      ],
    );
  }
}

class _MobileProvider extends StatelessWidget {
  final String name;
  final Color color;
  const _MobileProvider(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(name, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
