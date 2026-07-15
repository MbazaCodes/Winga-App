import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../data/chat_repository.dart';
import '../../domain/chat_message.dart';
import 'substitution_proposal_screen.dart';

final chatRepoProvider = Provider((_) => ChatRepository());

final chatStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, requestId) {
  return ref.read(chatRepoProvider).messageStream(requestId);
});

class ChatScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String wingaName;
  final bool isWinga; // whether current user is the Winga (not customer)

  const ChatScreen({
    super.key,
    required this.requestId,
    required this.wingaName,
    this.isWinga = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  String get _senderType => widget.isWinga ? 'winga' : 'customer';

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    try {
      await ref.read(chatRepoProvider).sendText(
            requestId: widget.requestId,
            text: text,
            senderType: _senderType,
          );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hitilafu: $e')));
    }
    if (mounted) setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(chatStreamProvider(widget.requestId));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.wingaName,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const Text('Online · mazungumzo ya ununuzi',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: WingaColors.textSecondary)),
          ],
        ),
        actions: [
          if (widget.isWinga)
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded,
                  color: WingaColors.primary),
              tooltip: 'Pendekeza mbadala',
              onPressed: () => context.push(
                  '/chat/${widget.requestId}/substitution?winga=${widget.wingaName}'),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded,
                color: WingaColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Messages ────────────────────────────────────────
          Expanded(
            child: msgs.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: WingaColors.primary)),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 48, color: WingaColors.textLight),
                        SizedBox(height: 12),
                        Text('Anza mazungumzo na Winga wako',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: WingaColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    msg: list[i],
                    isMe: list[i].senderId == WingaSession.safeUid,
                    onSubstitutionRespond: (subId, approved) async {
                      await ref.read(chatRepoProvider).respondSubstitution(
                            substitutionId: subId,
                            approved: approved,
                          );
                    },
                  ),
                );
              },
            ),
          ),

          // ── Input bar ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: WingaColors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                // Photo button
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      color: WingaColors.primary),
                  onPressed: () {},
                ),
                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Andika ujumbe...',
                        hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: WingaColors.textLight),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WingaColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: WingaShadows.button,
                  ),
                  child: IconButton(
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                    onPressed: _sending ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;
  final Future<void> Function(String subId, bool approved)?
      onSubstitutionRespond;

  const _MessageBubble(
      {required this.msg,
      required this.isMe,
      this.onSubstitutionRespond});

  @override
  Widget build(BuildContext context) {
    if (msg.isSystem) return _SystemMessage(text: msg.body ?? '');

    if (msg.isSubstitution) {
      return _SubstitutionCard(
          msg: msg,
          isCustomer: !isMe,
          onRespond: onSubstitutionRespond);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
                radius: 14,
                backgroundColor: WingaColors.primarySurface,
                child: Icon(Icons.person_rounded,
                    size: 16, color: WingaColors.primary)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: msg.isPhoto
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? WingaColors.primary : WingaColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isMe ? 18 : 4),
                  bottomRight:
                      Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: WingaShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.isPhoto && msg.photoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        msg.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: WingaColors.primarySurface,
                          child: const Icon(
                              Icons.broken_image_rounded,
                              color: WingaColors.primary),
                        ),
                      ),
                    ),
                  if (msg.body != null && msg.body!.isNotEmpty)
                    Text(
                      msg.body!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: isMe
                            ? Colors.white
                            : WingaColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    _time(msg.createdAt),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.6)
                          : WingaColors.textLight,
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

  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;
  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: WingaColors.primarySurface,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            text,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: WingaColors.primary),
          ),
        ),
      ),
    );
  }
}

class _SubstitutionCard extends StatefulWidget {
  final ChatMessage msg;
  final bool isCustomer; // true = show approve/reject
  final Future<void> Function(String, bool)? onRespond;

  const _SubstitutionCard(
      {required this.msg,
      required this.isCustomer,
      this.onRespond});

  @override
  State<_SubstitutionCard> createState() => _SubstitutionCardState();
}

class _SubstitutionCardState extends State<_SubstitutionCard> {
  bool _loading = false;

  Future<void> _respond(bool approved) async {
    final subId = widget.msg.metadata?['substitution_id'] as String?;
    if (subId == null || _loading) return;
    setState(() => _loading = true);
    await widget.onRespond?.call(subId, approved);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.msg.metadata ?? {};
    final original = meta['original'] as String? ?? '';
    final suggested = meta['suggested'] as String? ?? '';
    final reason = meta['reason'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WingaColors.gold.withOpacity(0.5)),
        boxShadow: WingaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  color: WingaColors.gold, size: 18),
              const SizedBox(width: 8),
              const Text('Ombi la Kubadilisha Bidhaa',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          _row('❌ Haipatikani:', original),
          _row('✅ Pendekezo:', suggested),
          if (reason != null) _row('📝 Sababu:', reason),
          if (widget.msg.photoUrl != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.msg.photoUrl!,
                  height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          if (widget.isCustomer) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => _respond(false),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: WingaColors.error,
                        side: const BorderSide(
                            color: WingaColors.error)),
                    child: const Text('Kataa',
                        style: TextStyle(fontFamily: 'Inter')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _respond(true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: WingaColors.primary),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white))
                        : const Text('Kubali',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WingaColors.textSecondary)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: WingaColors.textPrimary)),
            ),
          ],
        ),
      );
}
