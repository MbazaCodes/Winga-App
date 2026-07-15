class RequestModel {
  final String id;
  final String customerId;
  final String? wingaId;
  final String category;
  final String meetingPoint;
  final String shoppingArea;
  final String serviceType;    // 'hourly' | 'half_day' | 'full_day' | 'custom'
  final String deliveryMethod; // 'with_client' | 'deliver' | 'pickup'
  final int estimatedPrice;
  final int? finalPrice;
  final String status;         // 'searching' | 'accepted' | 'shopping' | 'completed' | 'cancelled'
  final String? note;
  final DateTime createdAt;
  final DateTime? completedAt;

  const RequestModel({
    required this.id,
    required this.customerId,
    this.wingaId,
    required this.category,
    required this.meetingPoint,
    required this.shoppingArea,
    required this.serviceType,
    required this.deliveryMethod,
    required this.estimatedPrice,
    this.finalPrice,
    required this.status,
    this.note,
    required this.createdAt,
    this.completedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> j) => RequestModel(
        id: j['id'] as String,
        customerId: j['customer_id'] as String,
        wingaId: j['winga_id'] as String?,
        category: j['category'] as String,
        meetingPoint: j['meeting_point'] as String,
        shoppingArea: j['shopping_area'] as String,
        serviceType: j['service_type'] as String,
        deliveryMethod: j['delivery_method'] as String,
        estimatedPrice: j['estimated_price'] as int,
        finalPrice: j['final_price'] as int?,
        status: j['status'] as String,
        note: j['note'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'winga_id': wingaId,
        'category': category,
        'meeting_point': meetingPoint,
        'shopping_area': shoppingArea,
        'service_type': serviceType,
        'delivery_method': deliveryMethod,
        'estimated_price': estimatedPrice,
        'final_price': finalPrice,
        'status': status,
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  RequestModel copyWith({
    String? wingaId,
    String? status,
    int? finalPrice,
    DateTime? completedAt,
  }) =>
      RequestModel(
        id: id,
        customerId: customerId,
        wingaId: wingaId ?? this.wingaId,
        category: category,
        meetingPoint: meetingPoint,
        shoppingArea: shoppingArea,
        serviceType: serviceType,
        deliveryMethod: deliveryMethod,
        estimatedPrice: estimatedPrice,
        finalPrice: finalPrice ?? this.finalPrice,
        status: status ?? this.status,
        note: note,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
