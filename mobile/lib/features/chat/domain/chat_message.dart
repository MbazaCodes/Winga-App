class ChatMessage {
  final String id;
  final String requestId;
  final String senderId;
  final String senderType; // customer | winga | system
  final String type; // text | photo | substitution | system | tip | location
  final String? body;
  final String? photoUrl;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderType,
    required this.type,
    this.body,
    this.photoUrl,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  bool get isPhoto => type == 'photo';
  bool get isSubstitution => type == 'substitution';
  bool get isSystem => type == 'system';

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        requestId: j['request_id'] as String,
        senderId: j['sender_id'] as String,
        senderType: j['sender_type'] as String,
        type: j['type'] as String? ?? 'text',
        body: j['body'] as String?,
        photoUrl: j['photo_url'] as String?,
        metadata: j['metadata'] as Map<String, dynamic>?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toInsert(String requestId) => {
        'request_id': requestId,
        'sender_id': senderId,
        'sender_type': senderType,
        'type': type,
        'body': body,
        'photo_url': photoUrl,
        'metadata': metadata,
      };
}

class SubstitutionRequest {
  final String id;
  final String requestId;
  final String originalItem;
  final int? originalPrice;
  final String suggestedItem;
  final int? suggestedPrice;
  final String? photoUrl;
  final String? reason;
  final String status; // pending | approved | rejected | cancelled
  final DateTime createdAt;

  const SubstitutionRequest({
    required this.id,
    required this.requestId,
    required this.originalItem,
    this.originalPrice,
    required this.suggestedItem,
    this.suggestedPrice,
    this.photoUrl,
    this.reason,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';

  factory SubstitutionRequest.fromJson(Map<String, dynamic> j) =>
      SubstitutionRequest(
        id: j['id'] as String,
        requestId: j['request_id'] as String,
        originalItem: j['original_item'] as String,
        originalPrice: j['original_price'] as int?,
        suggestedItem: j['suggested_item'] as String,
        suggestedPrice: j['suggested_price'] as int?,
        photoUrl: j['photo_url'] as String?,
        reason: j['reason'] as String?,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
