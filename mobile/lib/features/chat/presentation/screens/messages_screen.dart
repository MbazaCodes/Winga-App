import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final uid = WingaSession.safeUid;
    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      // Get requests for the user
      final reqs = await supabase
          .from('requests')
          .select('id, category, status, winga:wingas!winga_id(id, name)')
          .eq('customer_id', uid)
          .filter('status', 'in', '("accepted","shopping","completed")')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> convs = [];
      for (var req in (reqs as List)) {
        // Get last message
        final msgs = await supabase
            .from('messages')
            .select('body, created_at')
            .eq('request_id', req['id'])
            .order('created_at', ascending: false)
            .limit(1);

        // Count unread
        final unreadRes = await supabase
            .from('messages')
            .select('id')
            .eq('request_id', req['id'])
            .eq('is_read', false)
            .eq('sender_type', 'winga');

        final winga = req['winga'];
        if (winga == null) continue;

        convs.add({
          'requestId': req['id'],
          'wingaName': winga['name'] ?? 'Winga',
          'lastMessage': msgs.isNotEmpty ? msgs[0]['body'] : 'Gonga kuanza mazungumzo',
          'lastTime': msgs.isNotEmpty ? DateTime.parse(msgs[0]['created_at']) : DateTime.now(),
          'unread': (unreadRes as List).length,
          'status': req['status'],
          'category': req['category'],
        });
      }

      if (mounted) {
        setState(() {
          _conversations = convs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ujumbe 💬', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: WingaColors.primary))
        : _conversations.isEmpty
          ? _emptyState()
          : ListView.separated(
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 86),
              itemBuilder: (ctx, i) {
                final c = _conversations[i];
                return ListTile(
                  onTap: () => context.push('/chat/${c['requestId']}?winga=${c['wingaName']}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Stack(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                        child: const Center(child: Text('👤', style: TextStyle(fontSize: 26))),
                      ),
                      Positioned(
                        bottom: 1, right: 1,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: c['status'] == 'shopping' ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['wingaName'], style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: c['unread'] > 0 ? FontWeight.w700 : FontWeight.w600)),
                      Text(_formatTime(c['lastTime']), style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['category'], style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(c['lastMessage'],
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                                color: c['unread'] > 0 ? Colors.black : const Color(0xFF6B7280),
                                fontWeight: c['unread'] > 0 ? FontWeight.w600 : FontWeight.w400)),
                          ),
                          if (c['unread'] > 0)
                            Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: WingaColors.primary, shape: BoxShape.circle),
                              child: Center(child: Text('${c['unread']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
                );
              },
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💬', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Hakuna ujumbe bado', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Mazungumzo na Winga yako yataonekana hapa baada ya kukubali ombi lako',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/book'),
              style: ElevatedButton.styleFrom(backgroundColor: WingaColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Omba Winga Sasa →', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays < 1) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
