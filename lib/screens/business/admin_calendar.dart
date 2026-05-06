import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/business_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForDay(_selectedDay ?? DateTime.now());
    });
  }

  void _loadAppointmentsForDay(DateTime date) {
    final provider = Provider.of<BusinessProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    provider.fetchMyReservations(date: dateStr);
  }

  Future<void> _cancelAppointment(String id) async {
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
      await Provider.of<AppointmentProvider>(context, listen: false).cancelAppointment(id);
      if (mounted) {
        _loadAppointmentsForDay(_selectedDay ?? DateTime.now());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cancelada correctamente'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final appointments = provider.myReservations ?? [];

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
          
          Expanded(
            child: appointments.isEmpty
                ? Center(
                    child: Text('No hay citas para este día.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appt = appointments[index];
                      return _buildAppointmentCard(appt);
                    },
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
              color: isCancelled ? Colors.red : (isConfirmed ? Colors.green : Colors.orange),
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
                    if (servicePrice != null)
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
          if (!isCancelled)
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