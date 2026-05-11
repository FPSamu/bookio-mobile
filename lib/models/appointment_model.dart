import 'business_model.dart';
import 'user_model.dart';

class AppointmentModel {
  final String id;
  final String businessId;
  final String? clientId;
  final String? clientName;
  final String? clientPhone;
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
    this.clientId,
    this.clientName,
    this.clientPhone,
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
      clientName: json['client_name'],
      clientPhone: json['client_phone'],
      serviceId: json['service_id'],
      startDatetime: DateTime.parse(json['start_datetime']).toLocal(),
      endDatetime: DateTime.parse(json['end_datetime']).toLocal(),
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
    String? clientName,
    String? clientPhone,
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
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
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
