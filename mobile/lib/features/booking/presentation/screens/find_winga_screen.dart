import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class FindWingaScreen extends StatelessWidget {
  const FindWingaScreen({super.key});

  static const _wingas = [
    _WingaOption('Ahmed Juma', 4.9, 250, 'Electronics Expert', '0.2 km', true, '2 min ETA', 15000),
    _WingaOption('Bakari Said', 4.8, 180, 'General Expert', '0.3 km', true, '4 min ETA', 15000),
    _WingaOption('Hassan Ally', 4.7, 120, 'Hardware Expert', '0.5 km', true, '6 min ETA', 15000),
    _WingaOption('Fatuma Said', 4.9, 90, 'Clothing Expert', '0.6 km', false, '8 min ETA', 15000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WingaColors.primary), onPressed: () => context.pop()),
        title: const Text('Find a Winga'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: WingaStepIndicator(totalSteps: 6, currentStep: 4, labels: const ['Choose\nService', 'Details', 'Preferences', 'Find Winga', 'Request', 'Confirm']),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                const Center(child: Text('Available Wingas Nearby', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: WingaColors.primary))),
                const Center(child: Text('Select a Winga that best fits your needs.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: WingaColors.textSecondary))),
                const SizedBox(height: 16),
                // Map preview
                Container(
                  height: 150,
                  decoration: BoxDecoration(color: const Color(0xFFE8F0E4), borderRadius: BorderRadius.circular(16)),
                  child: Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(color: const Color(0xFFE8EDE9), child: GridView.builder(physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10), itemBuilder: (_, __) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.3)))))),
                      ...List.generate(4, (i) => Positioned(
                        left: [40.0, 100.0, 160.0, 60.0][i],
                        top: [50.0, 30.0, 70.0, 90.0][i],
                        child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: WingaColors.primary, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 14)),
                      )),
                      Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: WingaShadows.card), child: const Text('4 Wingas Available', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: WingaColors.primary)))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ..._wingas.map((w) => _WingaOptionCard(data: w, onSelect: () => context.push('/book/request'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WingaOption {
  final String name, specialty, distance, eta;
  final double rating;
  final int trips, price;
  final bool isOnline;
  const _WingaOption(this.name, this.rating, this.trips, this.specialty, this.distance, this.isOnline, this.eta, this.price);
}

class _WingaOptionCard extends StatelessWidget {
  final _WingaOption data;
  final VoidCallback onSelect;
  const _WingaOptionCard({required this.data, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: WingaColors.white, borderRadius: BorderRadius.circular(16), boxShadow: WingaShadows.card),
      child: Row(
        children: [
          Stack(
            children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: WingaColors.primarySurface, shape: BoxShape.circle, border: Border.all(color: WingaColors.primary, width: 2)), child: const Icon(Icons.person_rounded, size: 32, color: WingaColors.primary)),
              if (data.isOnline) Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.greenAccent.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(data.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_rounded, size: 14, color: WingaColors.primary),
                ]),
                RatingStars(rating: data.rating, count: data.trips, size: 12),
                const SizedBox(height: 4),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(100)), child: Text(data.specialty, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w500, color: WingaColors.primary))),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on_outlined, size: 11, color: WingaColors.textLight),
                  Text(data.distance, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: WingaColors.textSecondary)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data.eta, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.textSecondary)),
              const SizedBox(height: 6),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(backgroundColor: WingaColors.primary, padding: const EdgeInsets.symmetric(horizontal: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Select', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
