import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = StorageService.instance.getNotificationPrefs();
  }

  Future<void> _toggle(String key, bool value) async {
    await StorageService.instance.setNotificationPref(key, value);
    setState(() => _prefs[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('AVISOS', cs),
          _card([
            _switchTile(
              cs,
              key: 'new_appointment',
              icon: Icons.event_available_outlined,
              title: 'Nueva cita',
              subtitle: 'Confirmación al agendar',
            ),
            _divider(),
            _switchTile(
              cs,
              key: 'cancellation',
              icon: Icons.cancel_outlined,
              title: 'Cancelación',
              subtitle: 'Cuando el negocio cancela tu cita',
            ),
          ]),
          const SizedBox(height: 20),

          _sectionTitle('RECORDATORIOS', cs),
          _card([
            _switchTile(
              cs,
              key: 'reminder',
              icon: Icons.alarm_outlined,
              title: 'Recordatorio de cita',
              subtitle: 'Notificación antes de cada cita',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme cs) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: cs.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.shade100,
      ),
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    indent: 56,
  );

  Widget _switchTile(ColorScheme cs, {
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface.withValues(alpha: 0.7)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
      value: _prefs[key] ?? false,
      activeThumbColor: cs.secondary,
      onChanged: (v) => _toggle(key, v),
    );
  }
}
