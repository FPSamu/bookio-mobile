import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/business_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../services/business_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main_navigation.dart';
import 'appointment_detail_screen.dart';

class BookingScreen extends StatefulWidget {
  final BusinessModel business;
  final ServiceModel service;

  const BookingScreen({super.key, required this.business, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  
  List<Map<String, dynamic>> _businessSchedules = [];
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      final schedule = await BusinessService.instance.getBusinessSchedule(widget.business.id);
      setState(() {
        _businessSchedules = schedule;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      setState(() => _isLoadingSchedule = false);
    }
  }

  List<String> _getAvailableTimes() {
  if (_selectedDay == null || _businessSchedules.isEmpty) return [];

  final dbDay = _selectedDay!.weekday == 7 ? 0 : _selectedDay!.weekday;
  final dayData = _businessSchedules.firstWhere(
    (s) => s['day_of_week'] == dbDay,
    orElse: () => {},
  );

  if (dayData.isEmpty) return [];

  final startParts = (dayData['start_time'] as String).split(':');
  final endParts = (dayData['end_time'] as String).split(':');
  
  DateTime opening = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 
      int.parse(startParts[0]), int.parse(startParts[1]));
  DateTime closing = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, 
      int.parse(endParts[0]), int.parse(endParts[1]));

  // Duración del servicio que se quiere agendar AHORA
  final newServiceDuration = Duration(minutes: widget.service.durationMinutes);
  final lastSlotPossible = closing.subtract(newServiceDuration);

  // Obtener citas existentes para ese día
  final provider = context.read<AppointmentProvider>();
  final existingAppointments = provider.appointments.where((a) => 
      a.businessId == widget.business.id && 
      a.status != 'CANCELLED' && 
      isSameDay(a.startDatetime.toLocal(), _selectedDay!)
  ).toList();

  List<String> slots = [];
  DateTime current = opening;
  final interval = const Duration(minutes: 30); 

  while (current.isBefore(lastSlotPossible) || current.isAtSameMomentAs(lastSlotPossible)) {
    if (current.isAfter(DateTime.now())) {
      
      // --- LÓGICA DE TRASLAPE ---
      final slotStart = current;
      final slotEnd = current.add(newServiceDuration);

      bool isOverlap = false;

      for (var apt in existingAppointments) {
        final aptStart = apt.startDatetime.toLocal();
        // Asumimos que el modelo Appointment trae la duración del servicio
        final aptEnd = aptStart.add(Duration(minutes: apt.service?.durationMinutes ?? 30));

        // Condición de traslape: (Inicio1 < Fin2) && (Inicio2 < Fin1)
        if (slotStart.isBefore(aptEnd) && aptStart.isBefore(slotEnd)) {
          isOverlap = true;
          break;
        }
      }

      if (!isOverlap) {
        slots.add(DateFormat('HH:mm').format(current));
      }
    }
    current = current.add(interval);
  }

  return slots;
}

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reservar Cita')),
      body: _isLoadingSchedule 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildServiceInfo(cs),
                _buildCalendar(cs),
                if (_selectedDay != null) _buildTimeSlots(cs),
                const SizedBox(height: 30),
                if (_selectedTime != null) _buildConfirmButton(cs),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildServiceInfo(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(widget.service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${widget.service.durationMinutes} min'),
        trailing: Text('\$${widget.service.price}', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildCalendar(ColorScheme cs) {
    return TableCalendar(
      enabledDayPredicate: (day) {
        // Convertimos el día de Flutter al de tu DB (0=Dom...6=Sáb)
        final dbDay = day.weekday == 7 ? 0 : day.weekday;
        // Solo habilitamos el día si existe en los horarios del negocio
        return _businessSchedules.any((s) => s['day_of_week'] == dbDay);
      },
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (sel, foc) => setState(() { _selectedDay = sel; _focusedDay = foc; _selectedTime = null; }),
      calendarStyle: CalendarStyle(selectedDecoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
    );
  }

  Widget _buildTimeSlots(ColorScheme cs) {
    final times = _getAvailableTimes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Selecciona una hora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        times.isEmpty 
          ? const Center(child: Text('No hay horarios disponibles'))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                children: times.map((t) {
                  final isSel = _selectedTime == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSel,
                    onSelected: (val) => setState(() => _selectedTime = val ? t : null),
                    selectedColor: cs.primary,
                    labelStyle: TextStyle(color: isSel ? cs.onPrimary : cs.onSurface),
                  );
                }).toList(),
              ),
            ),
      ],
    );
  }

  Widget _buildConfirmButton(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        onPressed: _confirmBooking,
        child: const Text('Confirmar Reserva'),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<AppointmentProvider>();

    try {
      final parts = _selectedTime!.split(':');
      final localDt = DateTime(
        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      final utcDt = localDt.toUtc();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final newApt = await provider.createAppointment(
        widget.business.id, widget.service.id, utcDt,
      );

      final aptWithRelations = newApt.copyWith(
        business: widget.business,
        service: widget.service,
        status: 'CONFIRMED',
      );

      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation(userRole: 'CLIENT', initialIndex: 2)),
          (route) => false,
        );
        navigator.push(
          MaterialPageRoute(builder: (_) => _BookingSuccessPage(appointment: aptWithRelations)),
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ── SUCCESS ANIMATION PAGE ────────────────────────────────────────────────────

class _BookingSuccessPage extends StatefulWidget {
  final AppointmentModel appointment;
  const _BookingSuccessPage({required this.appointment});

  @override
  State<_BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<_BookingSuccessPage> with TickerProviderStateMixin {
  late final AnimationController _circleCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<double> _circleScale;
  late final Animation<double> _iconScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _circleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _circleScale = CurvedAnimation(parent: _circleCtrl, curve: Curves.elasticOut);
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleCtrl, curve: const Interval(0.4, 1.0, curve: Curves.elasticOut)),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    _circleCtrl.forward().then((_) => _contentCtrl.forward());

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => AppointmentDetailScreen(appointment: widget.appointment),
            transitionsBuilder: (_, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _circleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localStart = widget.appointment.startDatetime.toLocal();
    final dateStr = DateFormat("EEEE, d 'de' MMMM", 'es').format(localStart);
    final timeStr = DateFormat('h:mm a').format(localStart);
    final dateCap = '${dateStr[0].toUpperCase()}${dateStr.substring(1)}';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated checkmark circle
                ScaleTransition(
                  scale: _circleScale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4), width: 2),
                    ),
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Content
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      children: [
                        const Text(
                          '¡Cita Confirmada!',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu reserva ha sido procesada exitosamente',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Summary pill
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Column(
                            children: [
                              if (widget.appointment.business?.logoUrl != null)
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(widget.appointment.business!.logoUrl!),
                                  backgroundColor: Colors.white12,
                                ),
                              if (widget.appointment.business?.logoUrl != null) const SizedBox(height: 12),
                              Text(
                                widget.appointment.business?.name ?? '',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.appointment.service?.name ?? '',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$dateCap, $timeStr',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'Redirigiendo al detalle...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
