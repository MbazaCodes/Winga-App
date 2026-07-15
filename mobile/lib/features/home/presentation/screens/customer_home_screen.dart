import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
=======
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_button.dart';
import '../../../../core/widgets/winga_widgets.dart';
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
<<<<<<< HEAD
  final supabase = Supabase.instance.client;
  String _userName = '';
  List<dynamic> _wingas = [];
  List<dynamic> _topWingas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = WingaSession.safeUid;
    if (uid.isNotEmpty) {
      try {
        final user = await supabase.from('users').select('name').eq('id', uid).maybeSingle();
        if (user != null && user['name'] != null) {
          setState(() => _userName = user['name'].split(' ')[0]);
        }
      } catch (_) {}
    }

    try {
      final bestWingas = await supabase
          .from('wingas')
          .select()
          .eq('status', 'active')
          .eq('verification_status', 'verified')
          .order('winga_score', ascending: false)
          .order('rating', ascending: false)
          .limit(15);

      final top = await supabase
          .from('wingas')
          .select()
          .eq('status', 'active')
          .eq('is_top_rated', true)
          .order('winga_score', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _wingas = bestWingas;
          _topWingas = top;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Habari za asubuhi' : hour < 17 ? 'Habari za mchana' : 'Habari za jioni';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ── Sticky Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, bottom: 12, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/pick-city'),
                    child: Row(
                      children: const [
                        Text('📍', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text('Tanzania', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () => context.go('/messages'), icon: const Text('🔔', style: TextStyle(fontSize: 22))),
                      GestureDetector(
                        onTap: () => context.go('/profile'),
                        child: Container(
                          width: 36, height: 36,
                          decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                          child: const Center(child: Text('👤', style: TextStyle(fontSize: 18))),
=======
  final _searchCtrl = TextEditingController();
  int _notifCount = 3;
  String _currentCity = 'Kariakoo, Dar es Salaam';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
                            Text(
                              _currentCity,
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                ],
=======
                ),
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
<<<<<<< HEAD
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting 👋', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF6B7280))),
                  Text(_userName.isEmpty ? 'Karibu Winga! 👋' : 'Karibu, $_userName! 👋',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),

                  // Hero Banner
                  _mainHeroBanner(),
                  const SizedBox(height: 24),

                  // Categories Grid - UPGRADED
                  _sectionHeader('Huduma Maarufu', () => context.push('/categories'), actionLabel: 'Tazama Zote'),
                  const SizedBox(height: 16),
                  _categoriesGrid(),
                  const SizedBox(height: 24),

                  // Top Rated Section
                  if (_topWingas.isNotEmpty) ...[
                    _sectionHeader('⭐ Wingas Bora', () => context.go('/explore'), actionLabel: 'Zote'),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _topWingas.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (ctx, i) => _topWingaCard(_topWingas[i]),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  _sectionHeader('Wingas Bora Waliopo', () => context.go('/explore'), actionLabel: 'Tazama Zote'),
=======
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

<<<<<<< HEAD
          // Wingas List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _loading
              ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _wingaListTile(_wingas[i]),
                    childCount: _wingas.length,
                  ),
                ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _mainHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A5C2A), Color(0xFF0F3D1A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1A5C2A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unahitaji msaada\nwa manunuzi?',
            style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
          const SizedBox(height: 8),
          Text('Winga atakusaidia kupata bei bora na bidhaa halisi sokoni.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Omba Winga Sasa →', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _categoriesGrid() {
    final items = [
      ('🛠️', 'Fundi', 'fundi'),
      ('🏘️', 'Dalali', 'dalali'),
      ('📱', 'Elektroniki', 'electronics'),
      ('👕', 'Mavazi', 'clothing'),
      ('👟', 'Viatu', 'shoes'),
      ('💄', 'Vipodozi', 'beauty'),
      ('🔨', 'Ujenzi', 'hardware'),
      ('🍳', 'Nyumbani', 'kitchen'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
          onTap: () => context.push('/book?category=${items[i].$2}'),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Center(child: Text(items[i].$1, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 8),
              Text(items[i].$2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title, VoidCallback onTap, {String actionLabel = 'Zote'}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800)),
      GestureDetector(
        onTap: onTap,
        child: Text(actionLabel, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: WingaColors.primary))),
    ],
  );

  Widget _topWingaCard(dynamic w) => GestureDetector(
    onTap: () => context.push('/explore'),
    child: Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9A825).withOpacity(0.3), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 24, backgroundColor: Color(0xFFE8F5E9), child: Text('👤', style: TextStyle(fontSize: 24))),
          const SizedBox(height: 10),
          Text(w['name'].toString().split(' ')[0], maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700)),
          Text(w['specialty'], maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFF9A825), borderRadius: BorderRadius.circular(20)),
            child: const Text('⭐ TOP', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    ),
  );

  Widget _wingaListTile(dynamic w) => GestureDetector(
    onTap: () => context.push('/explore'),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Color(0xFFE8F5E9), child: Text('👤', style: TextStyle(fontSize: 28))),
              if (w['is_online'] == true)
                Positioned(bottom: 2, right: 2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF22C55E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(w['name'], style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700)),
                    _badge(w['badge']),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${w['specialty']} · ${w['current_area'] ?? "Mtaani"}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (w['rated_trips'] > 0) ...[
                      Text('👍 ${((w['winga_score'] ?? 0) * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.primary, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                    ],
                    Text('${w['total_trips'] ?? 0} Safari', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
=======
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
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: WingaColors.primary),
                      ],
                    ),
                  ),
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
        ],
      ),
    ),
  );

  Widget _badge(String? b) {
    if (b == null || b == 'none') return const SizedBox();
    String emoji = '🥉'; Color col = const Color(0xFFCD7F32);
    if (b == 'Verified') { emoji = '🥇'; col = const Color(0xFFF9A825); }
    else if (b == 'Mid') { emoji = '🥈'; col = const Color(0xFF9CA3AF); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Text('$emoji $b', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: col)),
=======
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
                  const SizedBox(width: 4),
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
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
    );
  }
}
