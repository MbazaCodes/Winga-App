import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/transaction_model.dart';
import '../../../core/utils/session.dart';
import '../../../core/constants/app_constants.dart';

class EarningsRepository {
  final _client = Supabase.instance.client;

  /// Get all transactions for current Winga
  Future<List<TransactionModel>> getTransactions() async {
    final rows = await _client
        .from('transactions')
        .select()
        .eq('winga_id', WingaSession.uid ?? '')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((r) => TransactionModel.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Calculate earnings summary
  Future<Map<String, int>> getEarningsSummary() async {
    final all = await getTransactions();
    final now = DateTime.now();

    int today = 0, thisWeek = 0, thisMonth = 0;
    for (final tx in all) {
      if (tx.status != 'success') continue;
      final diff = now.difference(tx.createdAt);
      if (diff.inDays == 0) today += tx.wingaPayout;
      if (diff.inDays < 7) thisWeek += tx.wingaPayout;
      if (tx.createdAt.month == now.month) thisMonth += tx.wingaPayout;
    }
    return {'today': today, 'thisWeek': thisWeek, 'thisMonth': thisMonth};
  }

  /// Create transaction after payment
  Future<TransactionModel> createTransaction({
    required String requestId,
    required String customerId,
    required int grossAmount,
    required String paymentMethod,
  }) async {
    final platformFee = (grossAmount * AppConstants.platformCommissionRate).round();
    final tax = (grossAmount * AppConstants.taxRateMin).round();
    final wingaPayout = grossAmount - platformFee - tax;

    final row = await _client.from('transactions').insert({
      'request_id': requestId,
      'winga_id': WingaSession.uid,
      'customer_id': customerId,
      'gross_amount': grossAmount,
      'platform_fee': platformFee,
      'winga_payout': wingaPayout,
      'tax': tax,
      'payment_method': paymentMethod,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return TransactionModel.fromJson(row as Map<String, dynamic>);
  }
}
