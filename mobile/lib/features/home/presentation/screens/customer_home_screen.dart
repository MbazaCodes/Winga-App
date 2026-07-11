import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchCtrl = TextEditingController();
  int _notifCount = 3;

  static const _categories = [
    ('📱', 'Elektroniki'),
    ('👕', 'Mavazi'),
    ('👟', 'Viatu'),
    ('💄', 'Vipodozi'),
    ('🔨', 'Vifaa vya Ujenzi'),
    ('🛋️', 'Samani'),
    ('🍳', 'Vifaa vya Nyumbani'),
    ('🚗', 'Magari & Spare Parts'),
    ('💊', 'Manukato'),
    ('⋯', 'Zaidi'),
  ];

  static const _nearbyWingas = [
    _WingaData(
      name: 'Ahmed Juma',
      rating: 4.9,
      trips: 250,
      specialty: 'Elektroniki Expert',
      distance: '0.2 km kutoka kwako',
      online: true,
    ),
    _WingaData(
      name: 'Bakari Said',
      rating: 4.8,
      trips: 180,
      specialty: 'Mavazi Expert',
      distance: '0.3 km kutoka kwako',
      online: true,
    ),
    _WingaData(
      name: 'Hassan Ally',
      rating: 4.7,
      trips: 120,
      specialty: 'Vifaa vya Ujenzi Expert',
      distance: '0.4 km kutoka kwako',
      online: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: WingaColors.white,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: WingaColors.primary, size: 20),
                            const SizedBox(width: 4),
                            const Text(
                              'Kariakoo',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: WingaColors.textPrimary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: WingaColors.textSecondary),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_outlined,
                                size: 26, color: WingaColors.textPrimary),
                            if (_notifCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: WingaColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$_notifCount',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  const Text(
                    'Karibu, John! 👋',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: WingaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tuko hapa kukusaidia ununuzi wako',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: WingaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero banner
                  _HeroBanner(onTap: () => context.push('/book/service')),
                  const SizedBox(height: 20),

                  // Search
                  _SearchBar(
                    controller: _searchCtrl,
                    onFilter: () {},
                  ),
                  const SizedBox(height: 24),

                  // Categories
                  SectionHeader(
                    title: 'Kategoria Maarufu',
                    action: 'Tazama zote',
                    onAction: () {},
                  ),
                  const SizedBox(height: 14),
                  _CategoriesGrid(categories: _categories),
                  const SizedBox(height: 24),

                  // Nearby wingas
                  SectionHeader(
                    title: 'Wingas Waliopo Karibu',
                    action: 'Tazama zote',
                    onAction: () {},
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Wingas horizontal list
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _nearbyWingas.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) => _WingaCard(
                  data: _nearbyWingas[i],
                  onTap: () => context.push('/book/service'),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: SafetyBanner(
                message:
                    'Usalama wako ni muhimu!\nWingas wetu wote ni walioidhinishwa na kupitishwa ukaguzi.',
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: WingaColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Opacity(
                opacity: 0.08,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8),
                  itemBuilder: (_, __) => const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pata Winga wako',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mwongozo wako wa kuaminika\nkatika Kariakoo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Omba Winga',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WingaColors.primary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: WingaColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rating badge
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.star_rounded, size: 16, color: WingaColors.gold),
                  SizedBox(width: 4),
                  Text(
                    '4.8\nKutoka kwa wateja 2,340+',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.3,
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
}

// ── Search Bar ─────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilter;

  const _SearchBar({required this.controller, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: WingaColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WingaColors.border),
              boxShadow: WingaShadows.card,
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    size: 20, color: WingaColors.textLight),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Unatafuta nini leo?',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: WingaColors.textLight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilter,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: WingaColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WingaColors.border),
              boxShadow: WingaShadows.card,
            ),
            child: const Icon(Icons.tune_rounded,
                size: 22, color: WingaColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ── Categories Grid ────────────────────────────────────────────────────────
class _CategoriesGrid extends StatelessWidget {
  final List<(String, String)> categories;

  const _CategoriesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => context.push('/book/service'),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: WingaColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: WingaColors.borderLight),
                boxShadow: WingaShadows.card,
              ),
              child: Center(
                child: Text(
                  categories[i].$1,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categories[i].$2,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: WingaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Winga Card (horizontal scroll) ────────────────────────────────────────
class _WingaData {
  final String name;
  final double rating;
  final int trips;
  final String specialty;
  final String distance;
  final bool online;

  const _WingaData({
    required this.name,
    required this.rating,
    required this.trips,
    required this.specialty,
    required this.distance,
    required this.online,
  });
}

class _WingaCard extends StatelessWidget {
  final _WingaData data;
  final VoidCallback onTap;

  const _WingaCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: WingaShadows.card,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Avatar + online dot
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: WingaColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: WingaColors.white, width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 34, color: WingaColors.primary),
              ),
              if (data.online)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: WingaColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          RatingStars(rating: data.rating, count: data.trips, size: 12),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              data.specialty,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: WingaColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 11, color: WingaColors.textLight),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  data.distance,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: WingaColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: WingaColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Omba',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
