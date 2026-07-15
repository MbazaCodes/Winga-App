import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/chat_message.dart';
import '../../../core/utils/session.dart';

class ChatRepository {
  final _client = Supabase.instance.client;

  /// Stream of messages for a request (Supabase Realtime)
  Stream<List<ChatMessage>> messageStream(String requestId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId)
        .order('created_at')
        .map((rows) => rows
            .map((r) => ChatMessage.fromJson(Map<String, dynamic>.from(r)))
            .toList());
  }

  /// Load message history (initial fetch)
  Future<List<ChatMessage>> loadHistory(String requestId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('request_id', requestId)
        .order('created_at');
    return (rows as List)
        .map((r) => ChatMessage.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Send a text message
  Future<ChatMessage> sendText({
    required String requestId,
    required String text,
    required String senderType,
  }) async {
    final row = await _client
        .from('messages')
        .insert({
          'request_id': requestId,
          'sender_id': WingaSession.safeUid,
          'sender_type': senderType,
          'type': 'text',
          'body': text,
        })
        .select()
        .single();
    return ChatMessage.fromJson(Map<String, dynamic>.from(row));
  }

  /// Upload a photo and send as message
  Future<ChatMessage> sendPhoto({
    required String requestId,
    required File file,
    required String senderType,
    String? caption,
  }) async {
    final uid = WingaSession.safeUid;
    final ext = file.path.split('.').last;
    final path = 'chat/$requestId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    // Upload to Supabase Storage
    await _client.storage.from('avatars').upload(path, file);
    final photoUrl = _client.storage.from('avatars').getPublicUrl(path);

    final row = await _client
        .from('messages')
        .insert({
          'request_id': requestId,
          'sender_id': uid,
          'sender_type': senderType,
          'type': 'photo',
          'body': caption,
          'photo_url': photoUrl,
        })
        .select()
        .single();
    return ChatMessage.fromJson(Map<String, dynamic>.from(row));
  }

  /// Mark messages in this request as read for the current user
  Future<void> markRead(String requestId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('request_id', requestId)
        .neq('sender_id', WingaSession.safeUid);
  }

  /// Count unread messages for the current user
  Future<int> unreadCount(String requestId) async {
    final res = await _client
        .from('messages')
        .select('id')
        .eq('request_id', requestId)
        .eq('is_read', false)
        .neq('sender_id', WingaSession.safeUid);
    return (res as List).length;
  }

  // ── Substitutions ──────────────────────────────────────────

  /// Winga proposes a substitution
  Future<Map<String, dynamic>> proposeSubstitution({
    required String requestId,
    required String originalItem,
    int? originalPrice,
    required String suggestedItem,
    int? suggestedPrice,
    String? photoUrl,
    String? reason,
  }) async {
    final res = await _client.rpc('propose_substitution', params: {
      'p_request_id': requestId,
      'p_original_item': originalItem,
      'p_original_price': originalPrice,
      'p_suggested_item': suggestedItem,
      'p_suggested_price': suggestedPrice,
      'p_photo_url': photoUrl,
      'p_reason': reason,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// Customer responds to substitution
  Future<Map<String, dynamic>> respondSubstitution({
    required String substitutionId,
    required bool approved,
    String? note,
  }) async {
    final res = await _client.rpc('respond_substitution', params: {
      'p_sub_id': substitutionId,
      'p_approved': approved,
      'p_note': note,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// Get pending substitutions for a request
  Future<List<SubstitutionRequest>> getPendingSubstitutions(
      String requestId) async {
    final rows = await _client
        .from('substitutions')
        .select()
        .eq('request_id', requestId)
        .eq('status', 'pending')
        .order('created_at');
    return (rows as List)
        .map((r) =>
            SubstitutionRequest.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }
}
