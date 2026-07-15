import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  String _name = '';
  String _phone = '';
  int _wallet = 0;
  int _requests = 0;
  int _completed = 0;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = WingaSession.safeUid;
    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final user = await supabase.from('users').select().eq('id', uid).maybeSingle();
      if (user != null) {
        _name = user['name'] ?? 'Mteja Mpya';
        _phone = user['phone'] ?? '';
        _wallet = user['wallet_balance'] ?? 0;
        _photoUrl = user['profile_image_url'];
      }

      final reqs = await supabase.from('requests').select('id, status').eq('customer_id', uid);
      _requests = (reqs as List).length;
      _completed = reqs.where((r) => r['status'] == 'completed').length;

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    await WingaSession.clear();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Green Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20, bottom: 28),
            decoration: const BoxDecoration(color: WingaColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wasifu Wangu', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Photo
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
                      ),
                      child: Center(
                        child: _photoUrl != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(38), child: Image.network(_photoUrl!, width: 76, height: 76, fit: BoxFit.cover))
                          : const Text('👤', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_phone, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.75))),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                            decoration: BoxDecoration(color: WingaColors.gold, borderRadius: BorderRadius.circular(20)),
                            child: const Text('MTEJA', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    const Text('✏️', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats
                  Row(
                    children: [
                      _statCard('🛍️', 'Safari', '$_requests'),
                      const SizedBox(width: 10),
                      _statCard('✅', 'Kukamilika', '$_completed'),
                      const SizedBox(width: 10),
                      _statCard('💰', 'Mkoba', 'TZS $_wallet'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Menu
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Column(
                      children: [
                        _menuItem('📋', 'Safari Zangu', 'Maombi yote ya ununuzi', () => context.push('/requests')),
                        _menuItem('💳', 'Matumizi', 'Historia ya malipo', () => context.push('/earnings')),
                        _menuItem('💬', 'Ujumbe', 'Mazungumzo na Wingas', () => context.go('/messages')),
                        _menuItem('🎁', 'Alika Marafiki', 'Pata bonasi ya rufaa', () => {}),
                        _menuItem('🔔', 'Taarifa', 'Mipangilio ya notisi', () => {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Join as Winga
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF9A825).withOpacity(0.4))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🛍️ Je, unataka kuwa Winga?', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF57F17))),
                        const SizedBox(height: 4),
                        const Text('Anza kutengeneza kipato kwa kusaidia wengine kufanya manunuzi.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280))),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push('/winga-register'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('Jiunge Kama Winga →', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        backgroundColor: const Color(0xFFFFF5F5),
                        side: const BorderSide(color: Color(0xFFFECACA)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('🚪 Ondoka kwenye Akaunti', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Winga App v1.3.0', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: WingaColors.primary)),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF6B7280))),
        ],
      ),
    ),
  );

  Widget _menuItem(String icon, String title, String sub, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        ],
      ),
    ),
  );
}
