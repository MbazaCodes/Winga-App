class TransactionModel {
  final String id;
  final String requestId;
  final String wingaId;
  final String customerId;
  final int grossAmount;
  final int platformFee;
  final int wingaPayout;
  final int tax;
  final String paymentMethod;  // 'mpesa' | 'airtel' | 'tigo' | 'halopesa' | 'wallet' | 'card'
  final String status;         // 'success' | 'pending' | 'failed' | 'refunded'
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.requestId,
    required this.wingaId,
    required this.customerId,
    required this.grossAmount,
    required this.platformFee,
    required this.wingaPayout,
    required this.tax,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
        id: j['id'] as String,
        requestId: j['request_id'] as String,
        wingaId: j['winga_id'] as String,
        customerId: j['customer_id'] as String,
        grossAmount: j['gross_amount'] as int,
        platformFee: j['platform_fee'] as int,
        wingaPayout: j['winga_payout'] as int,
        tax: j['tax'] as int,
        paymentMethod: j['payment_method'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
