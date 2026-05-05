import 'business_model.dart';
import 'user_model.dart';

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
      durationMinutes: json['duration_minutes'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      photoUrl: json['photo_url'],
    );
  }
}

class AppointmentModel {
  final String id;
  final String businessId;
  final String clientId;
  final String serviceId;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String status;
  final double? rating;
  final String? reviewText;

  final BusinessModel? business;
  final AppUser? client;
  final ServiceModel? service;

  AppointmentModel({
    required this.id,
    required this.businessId,
    required this.clientId,
    required this.serviceId,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    this.rating,
    this.reviewText,
    this.business,
    this.client,
    this.service,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      businessId: json['business_id'],
      clientId: json['client_id'],
      serviceId: json['service_id'],
      startDatetime: DateTime.parse(json['start_datetime']),
      endDatetime: DateTime.parse(json['end_datetime']),
      status: json['status'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewText: json['review_text'] as String?,
      business: json['business'] != null ? BusinessModel.fromJson(json['business']) : null,
      client: json['client'] != null ? AppUser.fromJson(json['client']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? businessId,
    String? clientId,
    String? serviceId,
    DateTime? startDatetime,
    DateTime? endDatetime,
    String? status,
    double? rating,
    String? reviewText,
    BusinessModel? business,
    AppUser? client,
    ServiceModel? service,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      business: business ?? this.business,
      client: client ?? this.client,
      service: service ?? this.service,
    );
  }
}
