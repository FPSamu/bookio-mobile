import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../services/appointment_service.dart';
import '../../models/appointment_model.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isScanned = true);
        _handleScan(barcode.rawValue!);
        break;
      }
    }
  }

  void _handleScan(String appointmentId) async {
    try {
      // Intentar obtener la cita directamente desde la lista local del provider primero
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      AppointmentModel? appointment;
      
      // Si no está en la lista local, podríamos necesitar un endpoint de fetch by ID
      // Por simplicidad, buscaremos en la lista actual o mostraremos error
      appointment = provider.myReservations?.firstWhere((a) => a.id == appointmentId);

      if (appointment != null) {
        _showAppointmentDetail(appointment);
      } else {
        _showError('Cita no encontrada en la lista actual. Asegúrate de que sea para hoy.');
      }
    } catch (e) {
      _showError('Error al procesar el código QR');
    }
  }

  void _showAppointmentDetail(AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('Detalle de la Cita', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailRow(Icons.person, 'Cliente', appointment.client?.name ?? appointment.clientName ?? 'N/A'),
            _detailRow(Icons.email, 'Email', appointment.client?.email ?? 'N/A'),
            _detailRow(Icons.phone, 'Teléfono', appointment.client?.phone ?? appointment.clientPhone ?? 'N/A'),
            _detailRow(Icons.spa, 'Servicio', appointment.service?.name ?? 'N/A'),
            _detailRow(Icons.access_time, 'Hora', DateFormat('hh:mm a').format(appointment.startDatetime)),
            const SizedBox(height: 32),
            if (appointment.status != 'CANCELLED' && appointment.status != 'COMPLETED') ...[
              if (appointment.status == 'PENDING' || appointment.status == 'CONFIRMED')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(appointment.id, 'IN_PROGRESS'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text('Iniciar Cita (En Curso)'),
                    ),
                  ),
                ),
              if (appointment.status == 'IN_PROGRESS')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(appointment.id, 'COMPLETED'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Marcar como Completada'),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _isScanned = false));
  }

  void _updateStatus(String id, String status) async {
    try {
      await AppointmentService.instance.updateAppointmentStatus(id, status);
      if (mounted) {
        Provider.of<BusinessProvider>(context, listen: false).fetchMyReservations();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado a $status')));
      }
    } catch (e) {
      _showError('No se pudo actualizar el estado');
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    setState(() => _isScanned = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
