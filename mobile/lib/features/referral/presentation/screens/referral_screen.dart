import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../../../core/widgets/winga_button.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  String? _code;
  int _walletBalance = 0;
  int _totalReferrals = 0;
  bool _loading = true;
  final _codeInputCtrl = TextEditingController();
  bool _applying = false;
  String? _applyResult;
  bool _applySuccess = false;

  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = WingaSession.safeUid;
    if (uid.isEmpty) return;

    // Get or generate referral code
    final refRows = await _client
        .from('referrals')
        .select('code')
        .eq('referrer_id', uid)
        .limit(1);

    String? code;
    if ((refRows as List).isEmpty) {
      final res = await _client
          .rpc('generate_referral_code', params: {'p_user_id': uid});
      code = res as String?;
    } else {
      code = refRows[0]['code'] as String;
    }

    // Wallet balance + referral count
    final userRow = await _client
        .from('users')
        .select('wallet_balance')
        .eq('id', uid)
        .single();
    final totalRef = await _client
        .from('referrals')
        .select('id')
        .eq('referrer_id', uid)
        .eq('status', 'used');

    if (mounted) {
      setState(() {
        _code = code;
        _walletBalance =
            (userRow['wallet_balance'] as num?)?.toInt() ?? 0;
        _totalReferrals = (totalRef as List).length;
        _loading = false;
      });
    }
  }

  Future<void> _applyCode() async {
    final code = _codeInputCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _applying = true;
      _applyResult = null;
    });

    try {
      final res = await _client.rpc('apply_referral_code', params: {
        'p_code': code,
        'p_new_user_id': WingaSession.safeUid,
      });
      final map = Map<String, dynamic>.from(res as Map);
      setState(() {
        _applySuccess = map['success'] == true;
        _applyResult = map['message'] ?? map['error'] ?? '';
      });
      if (map['success'] == true) _load();
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Alika Marafiki'),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(color: WingaColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [WingaColors.primary, Color(0xFF0F3D1A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('🎁',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        const Text(
                          'Alika Rafiki, Pata Tuzo!',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Rafiki yako anapata punguzo la 20%\nWewe unapata TZS 2,000 kwenye pochi yako',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wallet balance
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: '💰',
                          label: 'Pochi Yangu',
                          value: 'TZS $_walletBalance',
                          accent: WingaColors.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: '👥',
                          label: 'Waliojiunga',
                          value: '$_totalReferrals',
                          accent: WingaColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Your code
                  if (_code != null) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Code Yako ya Kualiika',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WingaColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: WingaColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _code!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: WingaColors.primary,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                color: WingaColors.primary),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: _code!));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Code imenakiliwa!'),
                                backgroundColor:
                                    WingaColors.primary,
                              ));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_rounded,
                                color: WingaColors.primary),
                            onPressed: () {
                              // Share via platform share sheet
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Apply someone else's code
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Una Code ya Rafiki?',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeInputCtrl,
                          textCapitalization:
                              TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'WNGA1234',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WingaColors.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        onPressed: _applying ? null : _applyCode,
                        child: _applying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Text('Tumia',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white)),
                      ),
                    ],
                  ),
                  if (_applyResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _applySuccess
                            ? WingaColors.primarySurface
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _applyResult!,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: _applySuccess
                                ? WingaColors.primary
                                : WingaColors.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WingaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: accent)),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: WingaColors.textSecondary)),
          ],
        ),
      );
}
