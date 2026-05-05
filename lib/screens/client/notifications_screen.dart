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

    final items = [
      _NotifItem(key: 'new_appointment', icon: Icons.event_available_outlined, title: 'Nueva cita', subtitle: 'Cuando una cita es agendada'),
      _NotifItem(key: 'reminder',       icon: Icons.alarm_outlined,            title: 'Recordatorio', subtitle: '24 horas antes de la cita'),
      _NotifItem(key: 'cancellation',   icon: Icons.cancel_outlined,           title: 'Cancelación', subtitle: 'Cuando una cita es cancelada'),
      _NotifItem(key: 'news',           icon: Icons.campaign_outlined,         title: 'Novedades', subtitle: 'Promociones y actualizaciones de Bookio'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.secondary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Las notificaciones push requieren permiso del sistema.',
                    style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildTile(context, cs, item)),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, ColorScheme cs, _NotifItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5)),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, size: 20, color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: Text(item.subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
        value: _prefs[item.key] ?? false,
        activeThumbColor: cs.secondary,
        onChanged: (v) => _toggle(item.key, v),
      ),
    );
  }
}

class _NotifItem {
  final String key;
  final IconData icon;
  final String title;
  final String subtitle;
  const _NotifItem({required this.key, required this.icon, required this.title, required this.subtitle});
}
