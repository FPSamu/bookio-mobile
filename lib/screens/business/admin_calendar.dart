import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/business_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../services/business_service.dart';
import '../../widgets/pending_feature_widget.dart';
import 'manual_appointment_screen.dart';
import 'qr_scanner_screen.dart';
import 'edit_business_screen.dart';
import '../client/business_detail_screen.dart';

class AdminCalendar extends StatefulWidget {
  const AdminCalendar({super.key});

  @override
  State<AdminCalendar> createState() => _AdminCalendarState();
}

class _AdminCalendarState extends State<AdminCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForDay(_selectedDay ?? DateTime.now());
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    try {
      final data = await BusinessService.instance.getMySchedules();
      final list = (data['schedules'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (mounted) setState(() => _schedules = list);
    } catch (_) {}
  }

  Map<String, dynamic>? _scheduleForDay(DateTime date) {
    // Dart weekday: Mon=1..Sun=7 → backend day_of_week: Sun=0..Sat=6
    final backendDay = date.weekday % 7;
    try {
      return _schedules.firstWhere((s) => s['day_of_week'] == backendDay);
    } catch (_) {
      return null;
    }
  }

  void _loadAppointmentsForDay(DateTime date) {
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    // Send local midnight as UTC so backend filter covers the full local day
    final localMidnight = DateTime(date.year, date.month, date.day);
    provider.fetchMyReservations(date: localMidnight.toUtc().toIso8601String());
  }

  Future<void> _cancelAppointment(String id) async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await provider.cancelAppointment(id);
      if (!mounted) return;
      _loadAppointmentsForDay(_selectedDay ?? DateTime.now());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada correctamente'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildScheduleBanner(DateTime date) {
    final schedule = _scheduleForDay(date);
    final cs = Theme.of(context).colorScheme;
    if (schedule == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.red.shade50,
        child: Row(
          children: [
            Icon(Icons.block, size: 16, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Text('Cerrado hoy', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: cs.primary.withValues(alpha: 0.07),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            '${schedule['start_time']} – ${schedule['end_time']}',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final selected = _selectedDay ?? DateTime.now();
    final appointments = (provider.myReservations ?? []).where((a) {
      return a.startDatetime.year == selected.year &&
          a.startDatetime.month == selected.month &&
          a.startDatetime.day == selected.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.week,
              availableCalendarFormats: const { CalendarFormat.week: 'Week' },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadAppointmentsForDay(selectedDay);
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                ),
                todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          _buildScheduleBanner(selected),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadAppointmentsForDay(_selectedDay ?? DateTime.now()),
              child: appointments.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'No hay citas para este día.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) => _buildAppointmentCard(appointments[index]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_fab',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualAppointmentScreen())).then((_) {
            _loadAppointmentsForDay(_selectedDay ?? DateTime.now());
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).cardColor),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appt) {
    final isConfirmed = appt.status == 'CONFIRMED';
    final isCompleted = appt.status == 'COMPLETED';
    final isCancelled = appt.status == 'CANCELLED';
    final timeStart = DateFormat('hh:mm a').format(appt.startDatetime);
    
    final clientName = appt.client?.name ?? appt.clientName ?? 'Desconocido';
    final clientEmail = appt.client?.email;
    final clientPhone = appt.client?.phone ?? appt.clientPhone;
    final serviceName = appt.service?.name ?? 'Servicio';
    final servicePrice = appt.service?.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStart.split(' ')[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: isCancelled ? Colors.grey : Theme.of(context).colorScheme.onSurface
                  ),
                ),
                Text(
                  timeStart.split(' ')[1],
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isCancelled
                  ? Colors.red
                  : isCompleted
                      ? Colors.teal
                      : isConfirmed
                          ? Colors.green
                          : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCancelled ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Completada', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
                      )
                    else if (servicePrice != null)
                      Text(
                        '\$${servicePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isCancelled ? Colors.grey : Theme.of(context).colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(clientName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                if (clientEmail != null || clientPhone != null) ...[
                  const SizedBox(height: 4),
                  if (clientEmail != null) 
                    Text('Email: $clientEmail', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  if (clientPhone != null) 
                    Text('Tel: $clientPhone', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ]
              ],
            ),
          ),
          if (!isCancelled && !isCompleted)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              onSelected: (value) {
                if (value == 'cancel') {
                  _cancelAppointment(appt.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancelar Cita', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}