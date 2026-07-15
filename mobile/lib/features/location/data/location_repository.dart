import 'package:supabase_flutter/supabase_flutter.dart';

class WingaLocation {
  final String id;
  final String country;
  final String region;
  final String city;
  final String? area;
  final double? lat;
  final double? lng;

  const WingaLocation({
    required this.id,
    required this.country,
    required this.region,
    required this.city,
    this.area,
    this.lat,
    this.lng,
  });

  String get displayName => area != null ? '$area, $city' : city;
  String get shortName => area ?? city;

  factory WingaLocation.fromJson(Map<String, dynamic> j) => WingaLocation(
        id: j['id'] as String,
        country: j['country'] as String? ?? 'Tanzania',
        region: j['region'] as String,
        city: j['city'] as String,
        area: j['area'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
      );
}

class LocationRepository {
  final _client = Supabase.instance.client;

  /// All active locations, grouped by city
  Future<List<WingaLocation>> getAllLocations() async {
    final rows = await _client
        .from('locations')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (rows as List)
        .map((r) => WingaLocation.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// All distinct cities
  Future<List<String>> getCities() async {
    final locs = await getAllLocations();
    return locs.map((l) => l.city).toSet().toList()..sort();
  }

  /// Areas in a city
  Future<List<WingaLocation>> getAreasInCity(String city) async {
    final rows = await _client
        .from('locations')
        .select()
        .eq('city', city)
        .eq('is_active', true)
        .order('sort_order');
    return (rows as List)
        .map((r) => WingaLocation.fromJson(Map<String, dynamic>.from(r)))
        .toList();
  }

  /// Search Wingas available in a location
  Future<List<Map<String, dynamic>>> findWingasInLocation({
    required String city,
    String? area,
    String? specialty,
    bool onlineOnly = false,
  }) async {
    var query = _client
        .from('wingas')
        .select('*')
        .eq('status', 'active')
        .eq('verification_status', 'verified')
        .eq('current_city', city);

    if (area != null) query = query.eq('current_area', area);
    if (specialty != null) query = query.eq('specialty', specialty);
    if (onlineOnly) query = query.eq('is_online', true);

    final rows = await query.order('winga_score', ascending: false).limit(50);
    return (rows as List)
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  /// Winga sets their current location
  Future<void> updateWingaLocation({
    required String wingaId,
    required String city,
    String? area,
    double? lat,
    double? lng,
  }) async {
    await _client.from('wingas').update({
      'current_city': city,
      'current_area': area,
      'current_lat': lat,
      'current_lng': lng,
      'is_online': true,
    }).eq('id', wingaId);
  }

  /// Broadcast live GPS position during active request
  Future<void> broadcastPosition({
    required String wingaId,
    required String requestId,
    required double lat,
    required double lng,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    await _client.from('winga_locations').insert({
      'winga_id': wingaId,
      'request_id': requestId,
      'lat': lat,
      'lng': lng,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'status': 'active',
    });
  }

  /// Stream of Winga's live position for a request
  Stream<Map<String, dynamic>?> livePositionStream(String requestId) {
    return _client
        .from('winga_locations')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId)
        .order('recorded_at', ascending: false)
        .limit(1)
        .map((rows) => rows.isEmpty
            ? null
            : Map<String, dynamic>.from(rows.first));
  }
}
