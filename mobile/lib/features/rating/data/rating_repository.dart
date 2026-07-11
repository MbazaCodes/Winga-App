import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/winga_reputation.dart';

class RatingRepository {
  final _client = Supabase.instance.client;

  /// Customer awards a point for a completed trip.
  ///   good == true  -> 1 point (huduma nzuri)
  ///   good == false -> 0 points (huduma mbaya)
  ///
  /// The database enforces the rules: only the customer on the request, only
  /// once per request, only after the request is completed.
  Future<WingaReputation> rate({
    required String requestId,
    required bool good,
    String? reason,
  }) async {
    final res = await _client.rpc('rate_winga', params: {
      'p_request_id': requestId,
      'p_point': good ? 1 : 0,
      'p_reason': reason,
    });

    final map = Map<String, dynamic>.from(res as Map);
    if (map['success'] != true) {
      throw Exception(map['error'] ?? 'Rating failed');
    }

    return WingaReputation(
      totalPoints: (map['total_points'] as num?)?.toInt() ?? 0,
      ratedTrips: (map['rated_trips'] as num?)?.toInt() ?? 0,
      pointRate: (map['point_rate'] as num?)?.toDouble() ?? 0,
      score: (map['score'] as num?)?.toDouble() ?? 0,
      isTopRated: false,
    );
  }

  /// Has this trip already been rated? Used to hide the rating prompt.
  Future<bool> isRated(String requestId) async {
    final row = await _client
        .from('winga_points')
        .select('id')
        .eq('request_id', requestId)
        .maybeSingle();
    return row != null;
  }

  /// Top-rated Wingas for the Home screen featured row.
  Future<List<Map<String, dynamic>>> featuredWingas({int limit = 10}) async {
    final rows =
        await _client.rpc('get_featured_wingas', params: {'p_limit': limit});
    return (rows as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  /// Full leaderboard, ranked by Wilson score.
  Future<List<Map<String, dynamic>>> leaderboard({int limit = 50}) async {
    final rows =
        await _client.from('v_winga_leaderboard').select().limit(limit);
    return (rows as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  /// Reputation for a single Winga.
  Future<WingaReputation> reputationOf(String wingaId) async {
    final row = await _client
        .from('wingas')
        .select('total_points, rated_trips, point_rate, winga_score, is_top_rated')
        .eq('id', wingaId)
        .maybeSingle();
    if (row == null) return WingaReputation.empty;
    return WingaReputation.fromJson(Map<String, dynamic>.from(row));
  }
}
