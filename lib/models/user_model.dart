/// Modelo de usuario sincronizado con la respuesta de `/auth/me`.
class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;       // 'CLIENT' | 'BUSINESS_OWNER'
  final String? phone;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id:        json['id']?.toString()    ?? '',
      email:     json['email']?.toString() ?? '',
      name:      json['name']?.toString()  ?? '',
      role:      json['role']?.toString()  ?? 'CLIENT',
      phone:     json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
    );
  }

  bool get isBusinessOwner => role == 'BUSINESS_OWNER';
  bool get isClient        => role == 'CLIENT';
}
