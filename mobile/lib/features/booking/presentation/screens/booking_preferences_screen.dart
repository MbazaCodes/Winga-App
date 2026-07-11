import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class BookingPreferencesScreen extends StatefulWidget {
  const BookingPreferencesScreen({super.key});
  @override
  State<BookingPreferencesScreen> createState() => _BookingPreferencesScreenState();
}

class _BookingPreferencesScreenState extends State<BookingPreferencesScreen> {
  final Set<int> _goals = {0};
  final Set<int> _languages = {0};
  bool _preferFemale = false;
  bool _isLoading = false;

  static const _goalOptions = ['Best Price', 'Original Products', 'Fast Shopping', 'Compare Multiple Shops', 'Bulk Buying', 'Quality over Price'];
  static const _languageOptions = ['Swahili', 'English', 'Arabic'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WingaColors.primary), onPressed: () => context.pop()),
        title: const Text('Your Preferences'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: WingaStepIndicator(totalSteps: 6, currentStep: 3,
                labels: const ['Choose\nService', 'Details', 'Preferences', 'Find Winga', 'Request', 'Confirm']),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(child: Text('Set Your Preferences', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: WingaColors.primary))),
                  const SizedBox(height: 6),
                  const Center(child: Text('Tell us your shopping style so we find the perfect Winga.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: WingaColors.textSecondary))),
                  const SizedBox(height: 24),
                  const Text('Shopping Goal (Select all that apply)', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _goalOptions.asMap().entries.map((e) {
                      final selected = _goals.contains(e.key);
                      return GestureDetector(
                        onTap: () => setState(() { if (selected) { _goals.remove(e.key); } else { _goals.add(e.key); } }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? WingaColors.primarySurface : WingaColors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: selected ? WingaColors.primary : WingaColors.border, width: selected ? 1.5 : 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selected) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.check_rounded, size: 14, color: WingaColors.primary)),
                              Text(e.value, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: selected ? WingaColors.primary : WingaColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Preferred Language', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: _languageOptions.asMap().entries.map((e) {
                      final selected = _languages.contains(e.key);
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() { _languages.clear(); _languages.add(e.key); }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? WingaColors.primarySurface : WingaColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: selected ? WingaColors.primary : WingaColors.border, width: selected ? 1.5 : 1),
                              ),
                              child: Text(e.value, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: selected ? WingaColors.primary : WingaColors.textSecondary)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Other Preferences', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 12),
                  WingaCard(
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person_outlined, size: 18, color: WingaColors.primary)),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Prefer Female Winga', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Request a female shopping guide', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                        ])),
                        Switch(value: _preferFemale, onChanged: (v) => setState(() => _preferFemale = v), activeColor: WingaColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(color: WingaColors.white, border: const Border(top: BorderSide(color: WingaColors.borderLight))),
            child: SafeArea(top: false, child: WingaButton(
              label: 'Find My Winga',
              trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              isLoading: _isLoading,
              height: 52,
              onPressed: () {
                setState(() => _isLoading = true);
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (mounted) { setState(() => _isLoading = false); context.push('/book/find-winga'); }
                });
              },
            )),
          ),
        ],
      ),
    );
  }
}
