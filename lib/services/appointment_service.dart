import '../models/appointment_model.dart';
import 'api_service.dart';

class AppointmentService {
  AppointmentService._();
  static final AppointmentService instance = AppointmentService._();

  final ApiService _api = ApiService.instance;

  Future<List<AppointmentModel>> getAppointments({String? status, String? businessId, String? clientId}) async {
    final Map<String, String> queryParams = {};
    if (status != null) queryParams['status'] = status;
    if (businessId != null) queryParams['businessId'] = businessId;
    if (clientId != null) queryParams['clientId'] = clientId;

    final queryString = queryParams.isEmpty ? '' : '?${Uri(queryParameters: queryParams).query}';
    final data = await _api.get('/appointments$queryString');
    final List<dynamic> listJson = data['data'] ?? data['appointments'] ?? (data is List ? data : []);
    return listJson.map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<AppointmentModel> createAppointment({
    required String businessId,
    required String serviceId,
    required DateTime startDatetime,
  }) async {
    final data = await _api.post('/appointments', body: {
      'businessId': businessId,
      'serviceId': serviceId,
      'startDatetime': startDatetime.toIso8601String(),
    });
    final dynamic aptJson = data['appointment'] ?? data['data'] ?? data;
    return AppointmentModel.fromJson(aptJson as Map<String, dynamic>);
  }

  Future<AppointmentModel> createManualAppointment({
    required String businessId,
    required String serviceId,
    required DateTime startDatetime,
    required String clientName,
    String? clientPhone,
  }) async {
    final data = await _api.post('/appointments/manual', body: {
      'businessId': businessId,
      'serviceId': serviceId,
      'startDatetime': startDatetime.toIso8601String(),
      'clientName': clientName,
      if (clientPhone != null && clientPhone.isNotEmpty) 'clientPhone': clientPhone,
    });
    final dynamic aptJson = data['appointment'] ?? data['data'] ?? data;
    return AppointmentModel.fromJson(aptJson as Map<String, dynamic>);
  }

  Future<AppointmentModel> updateAppointmentStatus(String id, String status) async {
    final data = await _api.put('/appointments/$id/status', body: {
      'status': status,
    });
    final dynamic aptJson = data['appointment'] ?? data;
    return AppointmentModel.fromJson(aptJson as Map<String, dynamic>);
  }

  Future<void> submitReview({
    required String appointmentId,
    required String businessId,
    required String clientId,
    required double score,
    String? comment,
  }) async {
    await _api.post('/reviews', body: {
      'appointmentId': appointmentId,
      'businessId': businessId,
      'clientId': clientId,
      'score': score,
      if (comment != null) 'comment': comment,
    });
  }
}
