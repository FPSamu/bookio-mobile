import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppointmentModel> get upcomingAppointments => _appointments.where((a) {
        return a.startDatetime.isAfter(DateTime.now()) &&
            a.status != 'CANCELLED' &&
            a.status != 'COMPLETED';
      }).toList();

  List<AppointmentModel> get pastAppointments => _appointments.where((a) {
        return a.startDatetime.isBefore(DateTime.now()) ||
            a.status == 'CANCELLED' ||
            a.status == 'COMPLETED';
      }).toList();

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await AppointmentService.instance.getAppointments();
      _appointments.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      final updated = await AppointmentService.instance.updateAppointmentStatus(id, 'CANCELLED');
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al cancelar la cita: $e');
    }
  }

  Future<AppointmentModel> createAppointment(String businessId, String serviceId, DateTime startDatetime) async {
    try {
      final newApt = await AppointmentService.instance.createAppointment(
        businessId: businessId,
        serviceId: serviceId,
        startDatetime: startDatetime,
      );
      _appointments.add(newApt);
      _appointments.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));
      notifyListeners();
      return newApt;
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  Future<void> submitReview({
    required String appointmentId,
    required String businessId,
    required String clientId,
    required double score,
    String? comment,
  }) async {
    try {
      await AppointmentService.instance.submitReview(
        appointmentId: appointmentId,
        businessId: businessId,
        clientId: clientId,
        score: score,
        comment: comment,
      );
      
      // Update local state if needed (optional, depends on if we want to show it immediately)
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          rating: score,
          reviewText: comment,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error al enviar la reseña: $e');
    }
  }
}
