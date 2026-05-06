import 'package:flutter/material.dart';
import 'client/appointments_screen.dart';
import 'settings_screen.dart';
import 'business/admin_calendar.dart';
import 'business/services.dart';
import 'client/client_explore_screen.dart';
import 'client/favorites_screen.dart';
import 'client/map_screen.dart';
import 'business/metrics_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userRole;
  final int initialIndex;

  const MainNavigation({super.key, required this.userRole, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.userRole == 'BUSINESS_OWNER';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white38 : Colors.grey.shade400;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200;

    final destinations = isOwner
        ? const [
            NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Agenda'),
            NavigationDestination(icon: Icon(Icons.list_alt), label: 'Servicios'),
            NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Métricas'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Negocio'),
          ]
        : const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
            NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(icon: Icon(Icons.event_note), label: 'Mis Citas'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ];

    final screens = isOwner
        ? [
            const AdminCalendar(),
            const ServicesScreen(),
            const MetricsScreen(),
            const SettingsScreen(isBusiness: true),
          ]
        : [
            const ClientExploreScreen(),
            const MapScreen(),
            const FavoritesScreen(),
            const AppointmentsScreen(),
            const SettingsScreen(isBusiness: false),
          ];

    return Scaffold(
      backgroundColor: bgColor,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 65,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: activeColor);
              }
              return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: inactiveColor);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(color: activeColor, size: 26);
              }
              return IconThemeData(color: inactiveColor, size: 24);
            }),
          ),
          child: NavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
