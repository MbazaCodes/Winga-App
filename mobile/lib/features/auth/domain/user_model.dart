class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String? name;
  final String? profileImageUrl;
  final String userType;      // 'customer' | 'winga' | 'admin'
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.name,
    this.profileImageUrl,
    required this.userType,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        phone: j['phone'] as String,
        email: j['email'] as String?,
        name: j['name'] as String?,
        profileImageUrl: j['profile_image_url'] as String?,
        userType: j['user_type'] as String? ?? 'customer',
        isVerified: j['is_verified'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'email': email,
        'name': name,
        'profile_image_url': profileImageUrl,
        'user_type': userType,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
      };
}
