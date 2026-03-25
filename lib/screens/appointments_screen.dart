import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/pending_feature_widget.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = MockData.appointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: appointments.isEmpty
          ? const Center(child: Text('No tienes citas programadas.'))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final apt = appointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(apt.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${apt.service}\n${apt.dateTime}'),
                    isThreeLine: true,
                    trailing: TextButton(
                      child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Cancelar cita (Eliminar de DB)'))),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
