import '../models/appointment_model.dart';
import 'api_service.dart';

class AppointmentService {
  AppointmentService._();
  static final AppointmentService instance = AppointmentService._();

  final ApiService _api = ApiService.instance;

  Future<List<AppointmentModel>> getAppointments({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _api.get('/appointments$query');
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
