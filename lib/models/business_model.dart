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
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
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
}
