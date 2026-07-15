import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
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
=======
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  static const _periods = [
    _PeriodData('Today', 'TZS 18,500', '+8.2%', true),
    _PeriodData('This Week', 'TZS 72,000', '+12.5%', true),
    _PeriodData('This Month', 'TZS 328,500', '+10.3%', true),
    _PeriodData('Last Month', 'TZS 298,000', '-6.4%', false),
    _PeriodData('Total Trips', '128', '', null),
  ];

  static const _transactions = [
    _TxData('Electronics Shopping', '10 May 2026, 10:30 AM', 15000, '📱'),
    _TxData('Grocery Shopping', '09 May 2026, 04:00 PM', 12000, '🛒'),
    _TxData('Pharmacy Shopping', '08 May 2026, 11:00 AM', 10000, '💊'),
    _TxData('Clothing Shopping', '07 May 2026, 02:30 PM', 8000, '👕'),
  ];
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded,
              size: 24, color: WingaColors.white),
          onPressed: () {},
        ),
        backgroundColor: WingaColors.background,
        title: const Text('Earnings',
            style: TextStyle(color: WingaColors.textPrimary)),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 26, color: WingaColors.textPrimary),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: WingaColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total earnings hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: WingaColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Total Earnings (After Tax)',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: Colors.white54),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'TZS 328,500',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'After 3% tax',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Wallet illustration
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: WingaColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded,
                            size: 38, color: Colors.white),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: WingaColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'W',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: WingaColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Period summary row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WingaColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: WingaShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: WingaColors.textLight),
                            const SizedBox(width: 4),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(p.period,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: WingaColors.textSecondary,
                            )),
                        const SizedBox(height: 4),
                        Text(p.amount,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: WingaColors.textPrimary,
                            )),
                        if (p.isPositive != null)
                          Row(
                            children: [
                              Icon(
                                p.isPositive!
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 12,
                                color: p.isPositive!
                                    ? WingaColors.success
                                    : WingaColors.error,
                              ),
                              Text(
                                p.change,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: p.isPositive!
                                      ? WingaColors.success
                                      : WingaColors.error,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Earnings breakdown
            WingaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Earnings Breakdown',
                          style: WingaTextStyles.headingSmall),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: const [
                            Text('This Month',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: WingaColors.textSecondary,
                                )),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: WingaColors.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _BreakdownRow(
                      dot: WingaColors.primary,
                      label: 'Service Fees',
                      amount: 'TZS 276,000'),
                  _BreakdownRow(
                      dot: WingaColors.gold,
                      label: 'Tips from Clients',
                      amount: 'TZS 32,000'),
                  _BreakdownRow(
                      dot: Colors.purple,
                      label: 'Bonuses & Promotions',
                      amount: 'TZS 20,500'),
                  const Divider(height: 20),
                  _BreakdownRow(
                      label: 'Gross Earnings',
                      amount: 'TZS 328,500',
                      bold: true),
                  _BreakdownRow(
                      label: 'Tax (3%)',
                      amount: '- TZS 9,855',
                      valueColor: WingaColors.error),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WingaColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Net Earnings (After Tax)',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: WingaColors.primary,
                            )),
                        Text('TZS 318,645',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: WingaColors.primary,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tax rate is between 3% to 5% as per TRA regulations.',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WingaColors.textLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Withdraw Earnings',
                    sub: 'Transfer money to your wallet',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.print_outlined,
                    title: 'Print Statement',
                    sub: 'Download or print',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent transactions
            SectionHeader(
              title: 'Recent Transactions',
              action: 'View All >',
              onAction: () {},
            ),
            const SizedBox(height: 12),

            ..._transactions.map((tx) => _TransactionRow(data: tx)),
          ],
        ),
      ),
    );
  }
}

class _PeriodData {
  final String period;
  final String amount;
  final String change;
  final bool? isPositive;
  const _PeriodData(this.period, this.amount, this.change, this.isPositive);
}

class _TxData {
  final String title;
  final String date;
  final int amount;
  final String emoji;
  const _TxData(this.title, this.date, this.amount, this.emoji);
}

class _BreakdownRow extends StatelessWidget {
  final Color? dot;
  final String label;
  final String amount;
  final bool bold;
  final Color? valueColor;

  const _BreakdownRow({
    this.dot,
    required this.label,
    required this.amount,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (dot != null)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            )
          else
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                color: bold ? WingaColors.textPrimary : WingaColors.textSecondary,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (bold ? WingaColors.textPrimary : WingaColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: WingaColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: WingaShadows.card,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: WingaColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WingaColors.primary,
                      )),
                  Text(sub,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: WingaColors.textSecondary,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: WingaColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final _TxData data;
  const _TransactionRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: WingaShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                Text(data.date,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: WingaColors.textSecondary,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ TZS ${_fmt(data.amount)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: WingaColors.success,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: WingaColors.successLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Completed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.successText,
                    )),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: WingaColors.textLight),
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
>>>>>>> 630074e69bf7ffb62fb17172b66a523961758412
}
