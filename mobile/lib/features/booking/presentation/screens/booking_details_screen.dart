import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});
  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _noteCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Kariakoo, Dar es Salaam');
  int _shopCount = 3;
  int _budget = 0;
  bool _isLoading = false;

  static const _budgets = ['< TZS 100K', 'TZS 100K–500K', 'TZS 500K–1M', '> TZS 1M', 'No Budget Limit'];

  @override
  void dispose() {
    _noteCtrl.dispose(); _locationCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WingaColors.primary), onPressed: () => context.pop()),
        title: const Text('Request Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: WingaStepIndicator(totalSteps: 6, currentStep: 2,
                labels: const ['Choose\nService', 'Details', 'Preferences', 'Find Winga', 'Request', 'Confirm']),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(child: Text('Tell us more details', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: WingaColors.primary))),
                  const SizedBox(height: 6),
                  const Center(child: Text('Help your Winga understand exactly what you need.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary))),
                  const SizedBox(height: 24),
                  const Text('Meeting Point', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: WingaColors.primary),
                      suffixIcon: GestureDetector(
                        onTap: () {},
                        child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.map_outlined, size: 16, color: WingaColors.primary)),
                      ),
                      hintText: 'Where should Winga meet you?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Number of Shops to Visit', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () { if (_shopCount > 1) setState(() => _shopCount--); },
                        child: Container(width: 44, height: 44,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: WingaColors.border)),
                          child: const Icon(Icons.remove_rounded, color: WingaColors.textPrimary)),
                      ),
                      Expanded(
                        child: Center(child: Text('$_shopCount Shops',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: WingaColors.primary))),
                      ),
                      GestureDetector(
                        onTap: () { if (_shopCount < 10) setState(() => _shopCount++); },
                        child: Container(width: 44, height: 44,
                          decoration: BoxDecoration(color: WingaColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Budget Range', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _budgets.asMap().entries.map((e) => GestureDetector(
                      onTap: () => setState(() => _budget = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _budget == e.key ? WingaColors.primarySurface : WingaColors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: _budget == e.key ? WingaColors.primary : WingaColors.border, width: _budget == e.key ? 1.5 : 1),
                        ),
                        child: Text(e.value,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                                color: _budget == e.key ? WingaColors.primary : WingaColors.textSecondary)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Additional Notes', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tell your Winga what you\'re looking for e.g. brand, color, size, condition...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WingaColors.primary, width: 1.5)),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SafetyBanner(message: 'Be specific for best results\nThe more details you provide, the better your Winga can serve you.'),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(color: WingaColors.white, border: const Border(top: BorderSide(color: WingaColors.borderLight))),
            child: SafeArea(top: false, child: WingaButton(
              label: 'Continue',
              trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              isLoading: _isLoading,
              height: 52,
              onPressed: () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted) { setState(() => _isLoading = false); context.push('/book/preferences'); }
                });
              },
            )),
          ),
        ],
      ),
    );
  }
}
