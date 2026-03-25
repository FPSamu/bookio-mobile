import 'package:flutter/material.dart';

import 'main_navigation.dart';

class RegisterSelectionScreen extends StatelessWidget {
  const RegisterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Bienvenido a Bookio!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Selecciona cómo quieres usar la plataforma:'),
            const SizedBox(height: 40),
            
            _buildSelectionCard(
              context,
              title: 'Soy Cliente',
              description: 'Busca servicios, reserva citas y gestiona tus horarios de forma fácil.',
              icon: Icons.person_search_rounded,
              color: Colors.blue,
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation(userRole: 'CLIENT'))),
            ),
            
            const SizedBox(height: 20),
            
            _buildSelectionCard(
              context,
              title: 'Soy un Negocio',
              description: 'Publica tus servicios, gestiona empleados y recibe reservaciones en línea.',
              icon: Icons.storefront_rounded,
              color: Colors.indigo,
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation(userRole: 'BUSINESS_OWNER'))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, {
    required String title, 
    required String description, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}