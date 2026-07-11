import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});
  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _tab = 0;

  static const _tabs = ['All', 'In Progress', 'Completed', 'Cancelled'];

  static final _requests = [
    _RequestData(
      id: 'WNG-2024-001',
      type: 'Electronics Shopping',
      emoji: '📱',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Ahmed Juma',
      date: '16 May 2026 • 09:15 AM',
      amount: 15000,
      status: RequestStatus.inProgress,
    ),
    _RequestData(
      id: 'WNG-2024-002',
      type: 'Grocery Shopping',
      emoji: '🛒',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Bakari Said',
      date: '15 May 2026 • 02:30 PM',
      amount: 12000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-003',
      type: 'Pharmacy Shopping',
      emoji: '💊',
      location: 'Mikocheni, Dar es Salaam',
      winga: 'Hassan Ally',
      date: '14 May 2026 • 11:00 AM',
      amount: 10000,
      status: RequestStatus.pending,
    ),
    _RequestData(
      id: 'WNG-2024-004',
      type: 'Clothing Shopping',
      emoji: '👕',
      location: 'Kinondoni, Dar es Salaam',
      winga: 'Omar Rashid',
      date: '13 May 2026 • 08:00 AM',
      amount: 25000,
      status: RequestStatus.cancelled,
    ),
    _RequestData(
      id: 'WNG-2024-005',
      type: 'Hardware & Tools',
      emoji: '🔨',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Juma Abdallah',
      date: '12 May 2026 • 03:45 PM',
      amount: 40000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-006',
      type: 'Shoes & Bags',
      emoji: '👟',
      location: 'Mwenge, Dar es Salaam',
      winga: 'Ali Mohamed',
      date: '11 May 2026 • 10:00 AM',
      amount: 15000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-007',
      type: 'Cosmetics & Beauty',
      emoji: '💄',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Fatuma Said',
      date: '10 May 2026 • 01:15 PM',
      amount: 15000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-008',
      type: 'Spare Parts',
      emoji: '🔧',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Ibrahim Musa',
      date: '09 May 2026 • 09:00 AM',
      amount: 25000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-009',
      type: 'Kitchen Utensils',
      emoji: '🍳',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Zakia Amani',
      date: '08 May 2026 • 04:00 PM',
      amount: 15000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-010',
      type: 'Furniture',
      emoji: '🛋️',
      location: 'Mwenge, Dar es Salaam',
      winga: 'Rashid Hamisi',
      date: '07 May 2026 • 11:30 AM',
      amount: 40000,
      status: RequestStatus.cancelled,
    ),
    _RequestData(
      id: 'WNG-2024-011',
      type: 'Stationery',
      emoji: '📎',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Mwana Baraka',
      date: '06 May 2026 • 02:00 PM',
      amount: 15000,
      status: RequestStatus.completed,
    ),
    _RequestData(
      id: 'WNG-2024-012',
      type: 'Electronics Shopping',
      emoji: '📱',
      location: 'Kariakoo, Dar es Salaam',
      winga: 'Ahmed Juma',
      date: '05 May 2026 • 10:00 AM',
      amount: 25000,
      status: RequestStatus.completed,
    ),
  ];

  List<_RequestData> get _filtered {
    switch (_tab) {
      case 1:
        return _requests
            .where((r) =>
                r.status == RequestStatus.inProgress ||
                r.status == RequestStatus.pending)
            .toList();
      case 2:
        return _requests
            .where((r) => r.status == RequestStatus.completed)
            .toList();
      case 3:
        return _requests
            .where((r) => r.status == RequestStatus.cancelled)
            .toList();
      default:
        return _requests;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() => _tab = _tabCtrl.index);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: Container(
              color: WingaColors.white,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          const Text(
                            'My Requests',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: WingaColors.primarySurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.filter_list_rounded,
                                    size: 16, color: WingaColors.primary),
                                const SizedBox(width: 4),
                                const Text('Filter',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: WingaColors.primary,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stats strip
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Row(
                        children: [
                          _StatPill(label: '12 Total', color: WingaColors.primary),
                          const SizedBox(width: 8),
                          _StatPill(label: '2 Active', color: WingaColors.inProgress),
                          const SizedBox(width: 8),
                          _StatPill(label: '8 Done', color: WingaColors.success),
                          const SizedBox(width: 8),
                          _StatPill(label: '2 Cancelled', color: WingaColors.error),
                        ],
                      ),
                    ),

                    // Tab bar
                    TabBar(
                      controller: _tabCtrl,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: WingaColors.primary,
                      unselectedLabelColor: WingaColors.textSecondary,
                      indicatorColor: WingaColors.primary,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Inter', fontSize: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      tabs: _tabs
                          .map((t) => Tab(text: t, height: 42))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: _filtered.isEmpty
            ? _EmptyState(tab: _tabs[_tab])
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _RequestCard(
                  data: _filtered[i],
                  onTap: () => context.push('/tracking/on-the-way'),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book/service'),
        backgroundColor: WingaColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Request',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 4,
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

enum RequestStatus { inProgress, completed, pending, cancelled }

class _RequestData {
  final String id, type, emoji, location, winga, date;
  final int amount;
  final RequestStatus status;
  const _RequestData({
    required this.id,
    required this.type,
    required this.emoji,
    required this.location,
    required this.winga,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class _RequestCard extends StatelessWidget {
  final _RequestData data;
  final VoidCallback onTap;
  const _RequestCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    Color statusBg;
    switch (data.status) {
      case RequestStatus.inProgress:
        statusColor = WingaColors.inProgress;
        statusBg = WingaColors.inProgressLight;
        statusLabel = 'In Progress';
        break;
      case RequestStatus.completed:
        statusColor = WingaColors.successText;
        statusBg = WingaColors.successLight;
        statusLabel = 'Completed';
        break;
      case RequestStatus.pending:
        statusColor = WingaColors.goldDark;
        statusBg = WingaColors.warningLight;
        statusLabel = 'Pending';
        break;
      case RequestStatus.cancelled:
        statusColor = WingaColors.error;
        statusBg = WingaColors.errorLight;
        statusLabel = 'Cancelled';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WingaColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: WingaShadows.card,
        ),
        child: Column(
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: WingaColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(data.emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.type,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: WingaColors.textLight),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(data.location,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        )),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1, color: WingaColors.borderLight),

            // Bottom info row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  // Winga
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: WingaColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded,
                              size: 14, color: WingaColors.primary),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            data.winga,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date
                  Expanded(
                    child: Text(
                      data.date,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WingaColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Amount + arrow
                  Row(
                    children: [
                      Text(
                        'TZS ${_fmt(data.amount)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          size: 16, color: WingaColors.textLight),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons for active
            if (data.status == RequestStatus.inProgress ||
                data.status == RequestStatus.pending) ...[
              const Divider(height: 1, color: WingaColors.borderLight),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(
                              color: WingaColors.border),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: WingaColors.textSecondary,
                            )),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WingaColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Track',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}

class _EmptyState extends StatelessWidget {
  final String tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: WingaColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No $tab Requests',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Your requests will appear here.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: WingaColors.textSecondary)),
        ],
      ),
    );
  }
}
