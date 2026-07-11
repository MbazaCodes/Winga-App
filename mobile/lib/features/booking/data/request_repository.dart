import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/request_model.dart';
import '../../../core/utils/session.dart';

class RequestRepository {
  final _client = Supabase.instance.client;

  /// Create a new shopping request
  Future<RequestModel> createRequest({
    required String category,
    required String meetingPoint,
    required String shoppingArea,
    required String serviceType,
    required String deliveryMethod,
    required int estimatedPrice,
    String? note,
  }) async {
    final row = await _client.from('requests').insert({
      'customer_id': WingaSession.uid,
      'category': category,
      'meeting_point': meetingPoint,
      'shopping_area': shoppingArea,
      'service_type': serviceType,
      'delivery_method': deliveryMethod,
      'estimated_price': estimatedPrice,
      'note': note,
      'status': 'searching',
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    return RequestModel.fromJson(row as Map<String, dynamic>);
  }

  /// Fetch all requests for the current customer
  Future<List<RequestModel>> getMyRequests() async {
    final rows = await _client
        .from('requests')
        .select()
        .eq('customer_id', WingaSession.uid!)
        .order('created_at', ascending: false);

    return (rows as List).map((r) => RequestModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Fetch requests assigned to current Winga
  Future<List<RequestModel>> getWingaRequests() async {
    final rows = await _client
        .from('requests')
        .select()
        .eq('winga_id', WingaSession.uid!)
        .order('created_at', ascending: false);

    return (rows as List).map((r) => RequestModel.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Winga accepts a request
  Future<void> acceptRequest(String requestId) async {
    await _client.from('requests').update({
      'winga_id': WingaSession.uid,
      'status': 'accepted',
    }).eq('id', requestId);
  }

  /// Update request status
  Future<void> updateStatus(String requestId, String status) async {
    await _client.from('requests').update({'status': status}).eq('id', requestId);
  }

  /// Cancel request
  Future<void> cancelRequest(String requestId) async {
    await _client.from('requests').update({'status': 'cancelled'}).eq('id', requestId);
  }

  /// Real-time subscription to a request
  Stream<RequestModel> watchRequest(String requestId) {
    return _client
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .map((rows) => RequestModel.fromJson(rows.first));
  }
}
