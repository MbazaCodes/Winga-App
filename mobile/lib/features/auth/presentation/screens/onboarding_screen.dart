import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = [
    _OnboardData(
      market: 'Kariakoo',
      features: [
        ('shield_outlined', 'Trusted', 'Wingas'),
        ('shopping_bag_outlined', 'Best Shops', 'Best Prices'),
        ('person_outlined', 'Safe & Secure', 'Always'),
      ],
    ),
    _OnboardData(
      market: 'Mwenge',
      features: [
        ('compare_arrows', 'Compare', 'Prices'),
        ('verified_outlined', 'Verified', 'Experts'),
        ('location_on_outlined', 'Live', 'Tracking'),
      ],
    ),
    _OnboardData(
      market: 'All Markets',
      features: [
        ('payments_outlined', 'Secure', 'Payments'),
        ('star_outlined', 'Top Rated', 'Wingas'),
        ('support_agent', '24/7', 'Support'),
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.primary,
      body: Stack(
        children: [
          // Background image overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    WingaColors.primaryDark.withOpacity(0.85),
                    WingaColors.primary.withOpacity(0.95),
                  ],
                ),
              ),
              // Subtle market pattern
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                ),
                itemCount: 50,
                itemBuilder: (_, i) => Icon(
                  [
                    Icons.storefront_outlined,
                    Icons.shopping_bag_outlined,
                    Icons.location_on_outlined,
                    Icons.person_outline_rounded,
                    Icons.star_outline_rounded,
                  ][i % 5],
                  size: 28,
                  color: WingaColors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),

          // Content
          PageView.builder(
            controller: _controller,
            onPageChanged: (p) => setState(() => _page = p),
            itemCount: _pages.length,
            itemBuilder: (ctx, i) => _OnboardPage(data: _pages[i]),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  children: [
                    // Dot indicator
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        dotColor: WingaColors.white.withOpacity(0.3),
                        activeDotColor: WingaColors.gold,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        spacing: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardData {
  final String market;
  final List<(String, String, String)> features;
  const _OnboardData({required this.market, required this.features});
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _OnboardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Logo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WingaColors.white.withOpacity(0.12),
                border: Border.all(
                  color: WingaColors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pin shape
                    Icon(
                      Icons.location_on_rounded,
                      size: 56,
                      color: WingaColors.white,
                    ),
                    Positioned(
                      top: 14,
                      child: Icon(
                        Icons.person_rounded,
                        size: 26,
                        color: WingaColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App name
            const Text(
              'WINGA',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: WingaColors.white,
                letterSpacing: 4,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 1.5,
                  color: WingaColors.gold,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'APP',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.gold,
                      letterSpacing: 5,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 1.5,
                  color: WingaColors.gold,
                ),
              ],
            ),
            const SizedBox(height: 12),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: WingaColors.white,
                ),
                children: [
                  const TextSpan(text: 'Your Trusted Guide\nIn '),
                  TextSpan(
                    text: data.market,
                    style: const TextStyle(
                      color: WingaColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Feature icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.features
                  .map((f) => _FeatureItem(
                        iconName: f.$1,
                        title: f.$2,
                        subtitle: f.$3,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 48),

            // Get started button (only on last page)
            if (true) ...[
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: WingaColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: WingaColors.white.withOpacity(0.2),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Anza Sasa →',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: WingaColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: WingaColors.white.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String iconName;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.iconName,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WingaColors.white.withOpacity(0.08),
            border: Border.all(
              color: WingaColors.gold.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            _getIcon(iconName),
            size: 26,
            color: WingaColors.gold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: WingaColors.white,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: WingaColors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'shield_outlined':
        return Icons.verified_user_outlined;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'person_outlined':
        return Icons.person_outlined;
      case 'compare_arrows':
        return Icons.compare_arrows_rounded;
      case 'verified_outlined':
        return Icons.verified_outlined;
      case 'location_on_outlined':
        return Icons.location_on_outlined;
      case 'payments_outlined':
        return Icons.payments_outlined;
      case 'star_outlined':
        return Icons.star_outline_rounded;
      case 'support_agent':
        return Icons.support_agent_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
}
