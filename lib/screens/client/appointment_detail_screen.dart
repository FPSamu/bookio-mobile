import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/appointment_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/static_map_preview.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  bool get _isUpcoming =>
      appointment.startDatetime.isAfter(DateTime.now()) &&
      appointment.status != 'CANCELLED';

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED': return const Color(0xFF16A34A);
      case 'PENDING':   return const Color(0xFFD97706);
      case 'CANCELLED': return const Color(0xFF6B7280);
      default:          return const Color(0xFF3B82F6);
    }
  }

  String _statusLabel(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED': return 'Confirmada';
      case 'PENDING':   return 'Pendiente';
      case 'CANCELLED': return 'Cancelada';
      default:          return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED': return Icons.check_circle_rounded;
      case 'PENDING':   return Icons.hourglass_empty_rounded;
      case 'CANCELLED': return Icons.cancel_rounded;
      default:          return Icons.info_rounded;
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el marcador')),
        );
      }
    }
  }

  Future<void> _launchMaps(BuildContext context) async {
    final b = appointment.business;
    if (b == null) return;
    Uri url;
    if (b.latitude != null && b.longitude != null) {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${b.latitude},${b.longitude}');
    } else if (b.address != null) {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(b.address!)}');
    } else {
      return;
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cancelar cita?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<AppointmentProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await provider.cancelAppointment(appointment.id);
                navigator.pop();
                messenger.showSnackBar(SnackBar(
                  content: const Text('Cita cancelada.'),
                  backgroundColor: Colors.indigo,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final business = appointment.business;
    final service = appointment.service;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final localStart = appointment.startDatetime.toLocal();
    final dateFormatted = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es').format(localStart);
    final timeFormatted = DateFormat('h:mm a').format(localStart);
    final dateCap = '${dateFormatted[0].toUpperCase()}${dateFormatted.substring(1)}';
    final shortId = appointment.id.length > 8
        ? appointment.id.substring(0, 8).toUpperCase()
        : appointment.id.toUpperCase();

    final statusColor = _statusColor(appointment.status);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Detalle de Cita', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          children: [
            // ── HERO ──────────────────────────────────────────────────
            _card(context, child: Column(
              children: [
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: business?.logoUrl != null ? NetworkImage(business!.logoUrl!) : null,
                  child: business?.logoUrl == null
                      ? Icon(Icons.store_rounded, size: 44, color: cs.onSurface.withValues(alpha: 0.3))
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  business?.name ?? 'Negocio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  service?.name ?? 'Servicio',
                  style: TextStyle(fontSize: 15, color: cs.secondary, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(appointment.status), size: 15, color: statusColor),
                      const SizedBox(width: 6),
                      Text(_statusLabel(appointment.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            )),

            // ── FECHA / HORA / DURACIÓN ───────────────────────────────
            _card(context, child: Column(
              children: [
                _infoRow(context, Icons.calendar_today_rounded, 'Fecha', dateCap, cs),
                _divider(context),
                _infoRow(context, Icons.access_time_rounded, 'Hora', timeFormatted, cs),
                if (service != null) ...[
                  _divider(context),
                  _infoRow(context, Icons.timer_outlined, 'Duración', '${service.durationMinutes} minutos', cs),
                ],
              ],
            )),

            // ── TELÉFONO ──────────────────────────────────────────────
            if (business?.phone != null)
              _card(context, child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.phone_rounded, color: cs.onSecondaryContainer, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teléfono', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(business!.phone!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _launchPhone(context, business.phone!),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Llamar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )),

            // ── CÓDIGO QR ─────────────────────────────────────────────
            _card(context, child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código QR', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text('Muéstralo al llegar', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: appointment.id));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('ID copiado'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '#$shortId',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: QrImageView(
                      data: appointment.id,
                      version: QrVersions.auto,
                      size: 180,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )),

            // ── UBICACIÓN ─────────────────────────────────────────────
            if (business != null)
              _card(context, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ubicación', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
                      TextButton.icon(
                        onPressed: () => _launchMaps(context),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('Abrir'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (business.latitude != null && business.longitude != null)
                    StaticMapPreview(
                      latitude: business.latitude!,
                      longitude: business.longitude!,
                      height: 160,
                      onTap: () => _launchMaps(context),
                    )
                  else
                    GestureDetector(
                      onTap: () => _launchMaps(context),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_outlined, color: cs.onSurface.withValues(alpha: 0.4)),
                              const SizedBox(width: 8),
                              Text('Ver en mapa', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (business.address != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(business.address!, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.65)))),
                      ],
                    ),
                  ],
                ],
              )),

            // ── CANCELAR ──────────────────────────────────────────────
            if (_isUpcoming) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmCancel(context),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar cita', style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, indent: 44, color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
    );
  }
}
