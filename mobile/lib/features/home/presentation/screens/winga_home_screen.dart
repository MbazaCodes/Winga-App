import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class WingaHomeScreen extends StatefulWidget {
  const WingaHomeScreen({super.key});

  @override
  State<WingaHomeScreen> createState() => _WingaHomeScreenState();
}

class _WingaHomeScreenState extends State<WingaHomeScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  bool _toggling = false;
  Map<String, dynamic>? _profile;
  List<dynamic> _availableReqs = [];
  List<dynamic> _myActive = [];
  int _todayEarnings = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToRequests();
  }

  void _subscribeToRequests() {
    supabase
        .channel('winga-global-room')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'requests',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'status',
              value: 'searching',
            ),
            callback: (payload) {
              _loadData();
            })
        .subscribe();
  }

  Future<void> _loadData() async {
    final uid = WingaSession.safeUid;
    if (uid.isEmpty) return;

    try {
      final winga = await supabase.from('wingas').select().eq('user_id', uid).maybeSingle();
      if (winga != null) {
        _profile = winga;

        // Load available searching requests
        if (winga['is_online'] == true && winga['profile_complete'] == true) {
          final searching = await supabase
              .from('requests')
              .select('*, customer:users!customer_id(name, phone)')
              .filter('winga_id', 'is', 'null')
              .eq('status', 'searching')
              .order('created_at', ascending: false)
              .limit(10);
          _availableReqs = (searching as List);
        } else {
          _availableReqs = [];
        }

        // Load my active requests
        final mine = await supabase
            .from('requests')
            .select('*, customer:users!customer_id(name, phone)')
            .eq('winga_id', winga['id'])
            .filter('status', 'in', '("accepted","shopping","completed")')
            .order('created_at', ascending: false)
            .limit(20);

        _myActive = (mine as List).where((r) => ['accepted', 'shopping'].contains(r['status'])).toList();

        final today = DateTime.now();
        _todayEarnings = (mine as List)
            .where((r) => r['status'] == 'completed' && DateTime.parse(r['created_at']).day == today.day)
            .fold(0, (sum, r) => sum + (r['total_price'] as int? ?? 0));
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleOnline() async {
    if (_profile == null || _toggling) return;
    if (_profile!['profile_complete'] != true) {
      context.push('/winga/profile');
      return;
    }

    setState(() => _toggling = true);
    final next = !(_profile!['is_online'] as bool);
    try {
      await supabase.from('wingas').update({'is_online': next}).eq('id', _profile!['id']);
      _profile!['is_online'] = next;
      if (next) _loadData(); else _availableReqs = [];
    } catch (_) {}
    setState(() => _toggling = false);
  }

  Future<void> _claim(String reqId) async {
    if (_profile == null) return;
    try {
      final res = await supabase
          .from('requests')
          .update({
            'winga_id': _profile!['id'],
            'status': 'accepted',
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reqId)
          .filter('winga_id', 'is', 'null')
          .eq('status', 'searching')
          .select();

      if ((res as List).isNotEmpty) {
        _loadData();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isOnline = _profile?['is_online'] == true;
    final incomplete = _profile?['profile_complete'] != true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(color: isOnline ? const Color(0xFF1A5C2A) : const Color(0xFF374151)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Habari,', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
                        Text('${_profile?['name']?.split(' ')[0] ?? "Winga"} 👋', style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        _badge(_profile?['badge'] ?? 'Starter'),
                      ],
                    ),
                    GestureDetector(
                      onTap: _toggleOnline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            if (_toggling)
                              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            else
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: incomplete ? Colors.red : (isOnline ? Colors.green : Colors.grey), shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(incomplete ? 'Wasifu Haujakamilika' : (isOnline ? 'Mtandaoni' : 'Nje'),
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statBox('Leo', 'TZS $_todayEarnings'),
                    const SizedBox(width: 10),
                    _statBox('Safari Zote', '${_profile?['total_trips'] ?? 0}'),
                    const SizedBox(width: 10),
                    _statBox('Alama', '${((_profile?['winga_score'] ?? 0) * 100).toInt()}%'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (incomplete) _completionBanner(),

                if (_availableReqs.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Maombi Mapya (${_availableReqs.length})', style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._availableReqs.map((r) => _requestCard(r, true)).toList(),
                  const SizedBox(height: 20),
                ],

                if (_myActive.isNotEmpty) ...[
                  const Text('🔵 Maombi Yanayoendelea', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._myActive.map((r) => _requestCard(r, false)).toList(),
                  const SizedBox(height: 20),
                ],

                const Text('Vitendo vya Haraka', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _quickAction('💰', 'Mapato', () => context.push('/winga/earnings')),
                    _quickAction('📋', 'Maombi', () => context.push('/winga/requests')),
                    _quickAction('👤', 'Wasifu', () => context.push('/winga/profile')),
                    _quickAction('📊', 'Alama', () => {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    ),
  );

  Widget _badge(String b) {
    String emoji = '🥉'; Color col = const Color(0xFFCD7F32);
    if (b == 'Verified') { emoji = '🥇'; col = const Color(0xFFF9A825); }
    else if (b == 'Mid') { emoji = '🥈'; col = const Color(0xFF9E9E9E); }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20)),
      child: Text('$emoji $b', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _completionBanner() => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), border: Border.all(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('🚫', style: TextStyle(fontSize: 28)),
            SizedBox(width: 12),
            Text('Wasifu Haujakamilika', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Lazima uwasilishe wasifu wako 100% kabla ya kupokea maombi.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.push('/winga/profile'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Maliza Wasifu Sasa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  Widget _requestCard(dynamic r, bool isGlobal) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isGlobal ? Colors.red : WingaColors.primary, width: 2),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(r['customer']?['name'] ?? 'Mteja', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold)),
            Text('TZS ${r['total_price'] ?? r['estimated_price']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.bold, color: WingaColors.primary)),
          ],
        ),
        const SizedBox(height: 4),
        Text('${r['category']} · ${r['service_type']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('📍 ${r['meeting_point']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
            const SizedBox(width: 12),
            Text('🛒 ${r['shopping_area']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
        if (r['note'] != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
            child: Text('📝 ${r['note']}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF374151))),
          ),
        ],
        const SizedBox(height: 12),
        if (isGlobal)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _claim(r['id']),
              style: ElevatedButton.styleFrom(backgroundColor: WingaColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('✅ Kubali Maombi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/chat/${r['id']}?winga=${r['customer']?['name'] ?? "Mteja"}&role=winga'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('💬 Ongea', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              if (r['status'] == 'accepted')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateStatus(r['id'], 'shopping'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('🛒 Anza', style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
      ],
    ),
  );

  Future<void> _updateStatus(String id, String status) async {
    await supabase.from('requests').update({'status': status}).eq('id', id);
    _loadData();
  }

  Widget _quickAction(String icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
