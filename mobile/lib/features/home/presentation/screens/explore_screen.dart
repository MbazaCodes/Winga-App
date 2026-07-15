import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class NearbyWingasScreen extends StatefulWidget {
  const NearbyWingasScreen({super.key});

  @override
  State<NearbyWingasScreen> createState() => _NearbyWingasScreenState();
}

class _NearbyWingasScreenState extends State<NearbyWingasScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  String _viewMode = 'discover'; // 'discover' or 'list'
  String _activeCategory = '';
  String _search = '';
  int _currentIndex = 0;
  List<dynamic> _wingas = [];
  List<dynamic> _filtered = [];

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWingas();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWingas() async {
    try {
      final data = await supabase
          .from('wingas')
          .select()
          .eq('status', 'active')
          .eq('verification_status', 'verified')
          .order('winga_score', ascending: false)
          .order('rating', ascending: false)
          .limit(100);

      if (mounted) {
        setState(() {
          _wingas = data;
          _applyFilters();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    var list = [..._wingas];
    if (_activeCategory.isNotEmpty) {
      list = list.where((w) => w['specialty'].toString().contains(_activeCategory)).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((w) =>
        w['name'].toString().toLowerCase().contains(q) ||
        w['specialty'].toString().toLowerCase().contains(q)
      ).toList();
    }
    setState(() {
      _filtered = list;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      body: Column(
        children: [
          // ── Sticky Header ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔍 Gundua Wingas',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            _modeBtn('🃏 Kadi', 'discover'),
                            _modeBtn('📋 Orodha', 'list'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) {
                              _search = v;
                              _applyFilters();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Tafuta kwa jina au utaalamu...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Content ───────────────────────────────────────────
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: WingaColors.primary))
              : _filtered.isEmpty
                ? _emptyState()
                : _viewMode == 'discover' ? _discoverView() : _listView(),
          ),
        ],
      ),
    );
  }

  Widget _modeBtn(String label, String mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? WingaColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(_search.isNotEmpty ? 'Hatujapata Winga' : 'Hakuna Wingas walio karibu',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _discoverView() {
    if (_currentIndex >= _filtered.length) return _emptyState();
    final winga = _filtered[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('${_currentIndex + 1} / ${_filtered.length} Wingas',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 12),
          // Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  // Photo Area
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: winga['is_online'] == true
                          ? [WingaColors.primary, WingaColors.primaryLight]
                          : [const Color(0xFF6B7280), const Color(0xFF9CA3AF)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: Center(
                      child: winga['profile_photo_url'] != null
                        ? CircleAvatar(radius: 45, backgroundImage: NetworkImage(winga['profile_photo_url']))
                        : const Text('👤', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(winga['name'], style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold)),
                            _badge(winga['badge']),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _chip('🏷️ ${winga['specialty']}', const Color(0xFFE8F5E9), WingaColors.primary),
                            if (winga['current_area'] != null)
                              _chip('📍 ${winga['current_area']}', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(winga['bio'] ?? 'Winga mzoefu wa soko hapa kukusaidia.',
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Nav
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navBtn('‹', _currentIndex > 0 ? () => setState(() => _currentIndex--) : null),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => context.push('/book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WingaColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('🤝 Chagua Sasa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              _navBtn('›', _currentIndex < _filtered.length - 1 ? () => setState(() => _currentIndex++) : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) {
        final w = _filtered[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: w['is_online'] == true ? Colors.green.withOpacity(0.3) : const Color(0xFFF3F4F6), width: 1.5),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor: const Color(0xFFE8F5E9),
                    backgroundImage: w['profile_photo_url'] != null ? NetworkImage(w['profile_photo_url']) : null,
                    child: w['profile_photo_url'] == null ? const Text('👤', style: TextStyle(fontSize: 26)) : null,
                  ),
                  if (w['is_online'] == true)
                    Positioned(
                      bottom: 1, right: 1,
                      child: Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF22C55E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5))),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w['name'], style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                        _badge(w['badge']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${w['specialty']}${w['current_area'] != null ? ' · ${w['current_area']}' : ''}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('👍 ${((w['winga_score'] ?? 0) * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: WingaColors.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Text('${w['total_trips'] ?? 0} Safari', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String? b) {
    String emoji = '🥉';
    Color color = const Color(0xFFCD7F32);
    if (b == 'Verified') { emoji = '🥇'; color = const Color(0xFFF9A825); }
    else if (b == 'Mid') { emoji = '🥈'; color = const Color(0xFF9E9E9E); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text('$emoji $b', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _chip(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: textCol)),
    );
  }

  Widget _navBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF3F4F6) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 22, color: Color(0xFF6B7280)))),
      ),
    );
  }
}
