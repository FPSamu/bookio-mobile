import 'package:flutter/material.dart';
import 'client/appointments_screen.dart';
import 'settings_screen.dart';
import 'business/admin_calendar.dart';
import 'business/services.dart';
import 'client/client_explore_screen.dart';
import 'business/metrics_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userRole;

  const MainNavigation({super.key, required this.userRole});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.userRole == 'BUSINESS_OWNER';

    final destinations = isOwner 
      ? const [
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Servicios'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Métricas'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Negocio'),
        ]
      : const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.event_note), label: 'Mis Citas'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ];

    final screens = isOwner 
      ? [const AdminCalendar(), const ServicesScreen(), const MetricsScreen(), const SettingsScreen(isBusiness: true)]
      : [const ClientExploreScreen(), const AppointmentsScreen(), const SettingsScreen(isBusiness: false)];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Aquí aplicamos el rediseño minimalista
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // Un borde superior súper sutil en lugar de una sombra pesada
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 65, // Una altura un poco más compacta
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent, // Quita el tinte morado/azul de Material 3
            indicatorColor: Colors.transparent, // Quita la pastilla de fondo al seleccionar
            
            // Estilo del texto dinámico (Negro si está seleccionado, Gris si no)
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black87
                );
              }
              return TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: Colors.grey[400]
              );
            }),
            
            // Estilo del ícono dinámico
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.black87, size: 26);
              }
              return IconThemeData(color: Colors.grey[400], size: 24);
            }),
          ),
          child: NavigationBar(
            elevation: 0, // Quitamos la elevación nativa porque usamos el borde del Container
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}