class ServiceModel {
  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final String? photoUrl;

  ServiceModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    this.photoUrl,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      durationMinutes: json['duration_minutes'] ?? json['durationMinutes'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      photoUrl: json['photo_url'] ?? json['photoUrl'],
    );
  }
}

class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String type;
  final String? address;
  final String? logoUrl;
  final List<String> photos;
  final double averageRating;
  final int reviewCount;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final List<ServiceModel> services;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.address,
    this.logoUrl,
    required this.photos,
    required this.averageRating,
    required this.reviewCount,
    this.latitude,
    this.longitude,
    this.phone,
    required this.services,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] ?? json['ownerId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] ?? json['logoUrl'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      averageRating: (json['average_rating'] ?? json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? json['reviewCount'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      services: (json['services'] as List<dynamic>?)
              ?.map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'type': type,
      'address': address,
      'logo_url': logoUrl,
      'photos': photos,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
    };
  }

  BusinessModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? type,
    String? address,
    String? logoUrl,
    List<String>? photos,
    double? averageRating,
    int? reviewCount,
    double? latitude,
    double? longitude,
    String? phone,
    List<ServiceModel>? services,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      photos: photos ?? this.photos,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      services: services ?? this.services,
    );
  }
}
