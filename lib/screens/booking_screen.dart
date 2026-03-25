import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/mock_data.dart';
import '../widgets/pending_feature_widget.dart';
import '../widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final Business business;
  final String serviceName;

  const BookingScreen({
    super.key,
    required this.business,
    required this.serviceName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  final List<String> _availableTimes = [
    '09:00', '10:00', '11:00', '12:00', '14:00', '15:00', '16:00'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar: ${widget.serviceName}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.business.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTime = null; // reset time
                  });
                },
              ),
              
              const SizedBox(height: 24),
              if (_selectedDay != null) ...[
                const Text(
                  'Horarios Disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _availableTimes.map((time) {
                    final isSelected = _selectedTime == time;
                    return ActionChip(
                      label: Text(time),
                      backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedTime = time;
                        });
                      },
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Confirmar Cita',
                  onPressed: () {
                    if (_selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona una hora primero'))
                      );
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Se guardará la cita en PostgreSQL')));
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
