/// A Winga's public reputation, driven by customer points.
///
/// [score] is a Wilson lower bound (0..1), NOT a raw percentage. It answers
/// "what is the worst this Winga's true quality is likely to be?", so a Winga
/// with 3/3 points does not outrank one with 90/90.
class WingaReputation {
  final int totalPoints; // good trips
  final int ratedTrips; // good + bad
  final double pointRate; // % good — display only
  final double score; // Wilson 0..1 — ranking
  final bool isTopRated;

  const WingaReputation({
    required this.totalPoints,
    required this.ratedTrips,
    required this.pointRate,
    required this.score,
    required this.isTopRated,
  });

  int get badTrips => ratedTrips - totalPoints;

  /// Fewer than 10 rated trips — not enough evidence to rank meaningfully.
  bool get isProvisional => ratedTrips < 10;

  String get pointsLabel => '$totalPoints/$ratedTrips';

  factory WingaReputation.fromJson(Map<String, dynamic> j) => WingaReputation(
        totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
        ratedTrips: (j['rated_trips'] as num?)?.toInt() ?? 0,
        pointRate: (j['point_rate'] as num?)?.toDouble() ?? 0,
        score: (j['winga_score'] as num?)?.toDouble() ?? 0,
        isTopRated: j['is_top_rated'] as bool? ?? false,
      );

  static const empty = WingaReputation(
    totalPoints: 0,
    ratedTrips: 0,
    pointRate: 0,
    score: 0,
    isTopRated: false,
  );
}
