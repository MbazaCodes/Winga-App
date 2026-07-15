import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _idx = 0;
  final List<Map<String, String>> _slides = [
    { 'title': 'Karibu Winga App!', 'sub': 'Mwongozo wako wa kuaminika katika masoko ya Tanzania', 'emoji': '🛍️', 'bg': '0xFF1A5C2A' },
    { 'title': 'Pata Winga Wako', 'sub': 'Wingas wetu ni wabobezi walioidhinishwa — watakusaidia kupata bidhaa bora kwa bei nzuri', 'emoji': '🤝', 'bg': '0xFF0F3D1A' },
    { 'title': 'Salama na Rahisi', 'sub': 'Lipa baada ya huduma. Fuatilia Winga wako wakati wote. Hakuna wasiwasi!', 'emoji': '🔒', 'bg': '0xFF1A5C2A' },
  ];

  void _next() {
    if (_idx < _slides.length - 1) {
      setState(() => _idx++);
    } else {
      WingaSession.setOnboarded();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _slides[_idx];
    final color = Color(int.parse(s['bg']!));

    return Scaffold(
      backgroundColor: color,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () { WingaSession.setOnboarded(); context.go('/login'); },
                style: TextButton.styleFrom(backgroundColor: Colors.white24, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text('Ruka', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
            const Spacer(),
            Text(s['emoji']!, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(s['title']!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
            const SizedBox(height: 24),
            Text(s['sub']!, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.white.withOpacity(0.8), height: 1.6)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8, width: i == _idx ? 24 : 8,
                decoration: BoxDecoration(color: i == _idx ? WingaColors.gold : Colors.white30, borderRadius: BorderRadius.circular(4)),
              )),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: WingaColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_idx < _slides.length - 1 ? 'Endelea →' : 'Anza Sasa →', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
