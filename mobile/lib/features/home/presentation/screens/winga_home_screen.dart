import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class WingaHomeScreen extends StatelessWidget {
  const WingaHomeScreen({super.key});

  static const _quickActions = [
    _QuickAction(Icons.shopping_bag_outlined, 'Shop for\nClient', WingaColors.primary),
    _QuickAction(Icons.local_shipping_outlined, 'Deliver\nItems', Color(0xFF1565C0)),
    _QuickAction(Icons.receipt_long_outlined, 'My\nRequests', Color(0xFF6A1B9A)),
    _QuickAction(Icons.account_balance_wallet_outlined, 'Earnings', Color(0xFFF57F17)),
  ];

  static const _recentRequests = [
    _ReqItem('Electronics Shopping', 'Kariakoo', '15,000', 'Completed', true),
    _ReqItem('Grocery Shopping', 'Mwenge', '12,000', 'In Progress', false),
    _ReqItem('Pharmacy Shopping', 'Mikocheni', '10,000', 'Pending', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: WingaColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.15),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    size: 30, color: Colors.white),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.shade400,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: WingaColors.primary, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Habari, Ahmed! 👋',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Online — Ready for requests',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Stack(
                              children: [
                                const Icon(Icons.notifications_outlined,
                                    size: 26, color: Colors.white),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: WingaColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Row(
                        children: [
                          _StatBox(label: 'Wallet Balance', value: 'TZS 32,500', icon: Icons.account_balance_wallet_outlined),
                          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _StatBox(label: '128 Trips', value: '4.9 ★', icon: Icons.star_rounded, valueColor: WingaColors.gold),
                          Container(width: 1, height: 50, color: Colors.white.withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          _StatBox(label: 'Completion', value: '98%', icon: Icons.check_circle_outline_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Online toggle card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          child: const Icon(Icons.toggle_on_rounded,
                              color: WingaColors.primary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('You are Online',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: WingaColors.primary,
                                  )),
                              Text('Clients can find and request you',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                        Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: WingaColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Quick Actions', style: WingaTextStyles.headingSmall),
                  const SizedBox(height: 14),

                  // Quick actions grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _quickActions.length,
                    itemBuilder: (ctx, i) {
                      final a = _quickActions[i];
                      return GestureDetector(
                        onTap: () {
                          if (i == 2) context.go('/winga-requests');
                          if (i == 3) context.go('/winga-earnings');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: a.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(a.icon, size: 28, color: a.color),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: WingaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Recent Requests',
                    action: 'View All',
                    onAction: () => context.go('/winga-requests'),
                  ),
                  const SizedBox(height: 12),

                  ..._recentRequests.map((r) => _RecentReqCard(data: r)),

                  const SizedBox(height: 20),

                  // Earnings this week
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [WingaColors.primary, WingaColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('This Week',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Colors.white60)),
                              const SizedBox(height: 4),
                              Text('TZS 72,000',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.arrow_upward_rounded,
                                      size: 12, color: Colors.greenAccent),
                                  Text('12.5% vs last week',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/winga-earnings'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            child: const Text('View All →',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? valueColor;
  const _StatBox({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: valueColor ?? Colors.white)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white60), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ReqItem {
  final String type, location, amount, status;
  final bool completed;
  const _ReqItem(this.type, this.location, this.amount, this.status, this.completed);
}

class _RecentReqCard extends StatelessWidget {
  final _ReqItem data;
  const _RecentReqCard({required this.data});

  @override
  Widget build(BuildContext context) {
    Color statusColor = data.completed ? WingaColors.successText : data.status == 'In Progress' ? WingaColors.inProgress : WingaColors.goldDark;
    Color statusBg = data.completed ? WingaColors.successLight : data.status == 'In Progress' ? WingaColors.inProgressLight : WingaColors.warningLight;

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
            width: 44, height: 44,
            decoration: BoxDecoration(color: WingaColors.primarySurface, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shopping_bag_outlined, color: WingaColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.type, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 11, color: WingaColors.textLight),
                  const SizedBox(width: 2),
                  Text(data.location, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: WingaColors.textSecondary)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('TZS ${data.amount}', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: WingaColors.primary)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(100)),
                child: Text(data.status, style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 16, color: WingaColors.textLight),
        ],
      ),
    );
  }
}
