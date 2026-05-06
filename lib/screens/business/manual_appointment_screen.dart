import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/business_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/business_model.dart';
import '../../services/appointment_service.dart';
import '../../services/business_service.dart';

class ManualAppointmentScreen extends StatefulWidget {
  const ManualAppointmentScreen({super.key});

  @override
  State<ManualAppointmentScreen> createState() => _ManualAppointmentScreenState();
}

class _ManualAppointmentScreenState extends State<ManualAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedServiceId;
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _clientName = '';
  String _clientPhone = '';

  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      final business = Provider.of<BusinessProvider>(context, listen: false).myBusiness;
      if (business != null) {
        _schedule = await BusinessService.instance.getBusinessSchedule(business.id);
        setState(() {});
      }
    } catch (_) {}
  }

  bool _isWithinSchedule(DateTime time) {
    if (_schedule.isEmpty) return true; // Si no hay horario definido, permitimos todo (o podríamos bloquearlo)
    
    // day_of_week en backend suele ser 0-6 (Dom-Sab) o 1-7. 
    // DateTime.weekday es 1-7 (Lun-Dom).
    // Vamos a mapear Lun=1 -> day_of_week=1, etc. Dom=7 -> day_of_week=0.
    int dayToMatch = time.weekday == 7 ? 0 : time.weekday;
    
    final daySchedule = _schedule.firstWhere(
      (s) => s['day_of_week'] == dayToMatch,
      orElse: () => {},
    );

    if (daySchedule.isEmpty || daySchedule['is_closed'] == true) return false;

    final openStr = daySchedule['opening_time'] as String; // "HH:mm"
    final closeStr = daySchedule['closing_time'] as String; // "HH:mm"

    final open = TimeOfDay(
      hour: int.parse(openStr.split(':')[0]),
      minute: int.parse(openStr.split(':')[1]),
    );
    final close = TimeOfDay(
      hour: int.parse(closeStr.split(':')[0]),
      minute: int.parse(closeStr.split(':')[1]),
    );

    final current = TimeOfDay.fromDateTime(time);
    
    double currentVal = current.hour + current.minute / 60.0;
    double openVal = open.hour + open.minute / 60.0;
    double closeVal = close.hour + close.minute / 60.0;

    return currentVal >= openVal && currentVal < closeVal;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona un servicio')));
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona fecha y hora')));
      return;
    }

    final startDatetime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!_isWithinSchedule(startDatetime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La hora seleccionada está fuera del horario de apertura del negocio'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      
      final business = businessProvider.myBusiness;
      if (business == null) throw Exception('No se encontró el negocio');

      final startDatetime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Usamos el servicio directamente ya que el provider client-side asume crear para sí mismo
      // o extendemos AppointmentProvider para soportar walk-ins.
      // Aquí llamaremos al API service directamente para simplificar.
      
      await AppointmentService.instance.createManualAppointment(
        businessId: business.id,
        serviceId: _selectedServiceId!,
        startDatetime: startDatetime,
        clientName: _clientName,
        clientPhone: _clientPhone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita manual creada'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = Provider.of<BusinessProvider>(context).myBusiness;
    final services = business?.services ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cita Manual'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datos del Cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                    onSaved: (val) => _clientName = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Teléfono (Opcional)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    onSaved: (val) => _clientPhone = val ?? '',
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Servicio y Horario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Servicio', border: OutlineInputBorder()),
                    value: _selectedServiceId,
                    items: services.map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.name} (${s.durationMinutes} min)'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedServiceId = val),
                    validator: (val) => val == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (d != null) setState(() => _selectedDate = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder()),
                            child: Text(_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Seleccionar'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime ?? TimeOfDay.now(),
                            );
                            if (t != null) setState(() => _selectedTime = t);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder()),
                            child: Text(_selectedTime != null ? _selectedTime!.format(context) : 'Seleccionar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Crear Cita', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }
}
