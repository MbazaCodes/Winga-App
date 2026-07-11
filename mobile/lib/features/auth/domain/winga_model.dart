class WingaModel {
  final String id;
  final String wingaId;       // e.g. WNGA12345
  final String userId;
  final String name;
  final String phone;
  final String? email;
  final String specialty;
  final double rating;
  final int totalTrips;
  final double completionRate;
  final int totalEarnings;
  final String status;        // 'active' | 'inactive' | 'suspended' | 'pending'
  final String badge;         // 'bronze' | 'silver' | 'gold'
  final bool isVerified;
  final String? nationalId;
  final String homeLocation;
  final DateTime joinedAt;

  const WingaModel({
    required this.id,
    required this.wingaId,
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    required this.specialty,
    required this.rating,
    required this.totalTrips,
    required this.completionRate,
    required this.totalEarnings,
    required this.status,
    required this.badge,
    required this.isVerified,
    this.nationalId,
    required this.homeLocation,
    required this.joinedAt,
  });

  factory WingaModel.fromJson(Map<String, dynamic> j) => WingaModel(
        id: j['id'] as String,
        wingaId: j['winga_id'] as String,
        userId: j['user_id'] as String,
        name: j['name'] as String,
        phone: j['phone'] as String,
        email: j['email'] as String?,
        specialty: j['specialty'] as String? ?? 'General',
        rating: (j['rating'] as num?)?.toDouble() ?? 5.0,
        totalTrips: j['total_trips'] as int? ?? 0,
        completionRate: (j['completion_rate'] as num?)?.toDouble() ?? 100.0,
        totalEarnings: j['total_earnings'] as int? ?? 0,
        status: j['status'] as String? ?? 'pending',
        badge: j['badge'] as String? ?? 'bronze',
        isVerified: j['is_verified'] as bool? ?? false,
        nationalId: j['national_id'] as String?,
        homeLocation: j['home_location'] as String? ?? '',
        joinedAt: DateTime.parse(j['joined_at'] as String),
      );
}
