import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class EarningsScreen extends StatefulWidget {
  final bool isWinga;
  const EarningsScreen({super.key, this.isWinga = false});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  String _period = 'month'; // 'week', 'month', 'all'
  int _total = 0;
  int _balance = 0;
  List<dynamic> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = WingaSession.safeUid;
    if (uid.isEmpty) return;
    setState(() => _loading = true);

    try {
      if (widget.isWinga) {
        final winga = await supabase.from('wingas').select().eq('user_id', uid).maybeSingle();
        if (winga != null) {
          _balance = winga['total_earnings'] ?? 0;
          final trips = await supabase
              .from('requests')
              .select('*, customer:users!customer_id(name)')
              .eq('winga_id', winga['id'])
              .eq('status', 'completed')
              .order('created_at', ascending: false);
          _trips = trips;
          _total = _trips.fold(0, (sum, r) => sum + (r['total_price'] as int? ?? 0));
        }
      } else {
        final user = await supabase.from('users').select('wallet_balance').eq('id', uid).maybeSingle();
        if (user != null) {
          _balance = user['wallet_balance'] ?? 0;
          final trips = await supabase
              .from('requests')
              .select('*, winga:wingas!winga_id(name)')
              .eq('customer_id', uid)
              .eq('status', 'completed')
              .order('created_at', ascending: false);
          _trips = trips;
          _total = _trips.fold(0, (sum, r) => sum + (r['total_price'] as int? ?? 0));
        }
      }
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 24),
            decoration: const BoxDecoration(color: WingaColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.isWinga ? 'Mapato Yangu 💰' : 'Matumizi Yangu 💳',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _headerStat(widget.isWinga ? 'Jumla ya Mapato' : 'Jumla ya Malipo', 'TZS $_total'),
                    const SizedBox(width: 12),
                    _headerStat('Pochi Yangu', 'TZS $_balance', color: const Color(0xFF4ADE80)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Period tabs
                Row(
                  children: [
                    _periodBtn('Wiki', 'week'),
                    const SizedBox(width: 8),
                    _periodBtn('Mwezi', 'month'),
                    const SizedBox(width: 8),
                    _periodBtn('Yote', 'all'),
                  ],
                ),
                const SizedBox(height: 20),

                Text('${_trips.length} Safari', style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_trips.isEmpty)
                  _emptyState()
                else
                  ..._trips.map((t) => _transactionItem(t)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, {Color color = const Color(0xFFF9A825)}) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    ),
  );

  Widget _periodBtn(String label, String p) {
    final active = _period == p;
    return GestureDetector(
      onTap: () => setState(() { _period = p; _loadData(); }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: active ? WingaColors.primary : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : const Color(0xFF6B7280))),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('🛍️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text('Hakuna safari zilizopatikana', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    ),
  );

  Widget _transactionItem(dynamic t) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3F4F6))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isWinga ? (t['customer']?['name'] ?? 'Mteja') : (t['winga']?['name'] ?? 'Winga'),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${t['service_type']} · ${_formatDate(t['created_at'])}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
        Text('${widget.isWinga ? "+" : "-"} TZS ${t['total_price']}',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: widget.isWinga ? Colors.green : Colors.red)),
      ],
    ),
  );

  String _formatDate(String iso) {
    final d = DateTime.parse(iso);
    return '${d.day}/${d.month}/${d.year}';
  }
}
