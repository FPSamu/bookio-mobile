import 'package:flutter/material.dart';
import '../main.dart'; // To access global state
import '../widgets/pending_feature_widget.dart';
import 'login_screen.dart';
import 'client/business_detail_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool isBusiness;
  const SettingsScreen({super.key, this.isBusiness = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes y Perfil'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Usuario de Prueba',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'usuario@bookio.com',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Cuenta'),
          _buildListTile(context, 'Editar Perfil', Icons.person_outline),
          _buildListTile(context, 'Notificaciones', Icons.notifications_none),
          
          const Divider(),
          _buildSectionTitle('Preferencias'),
          _buildListTile(context, 'Idioma', Icons.language),
          ValueListenableBuilder<bool>(
            valueListenable: BookioApp.isDarkModeNotifier,
            builder: (context, isDark, _) {
              return SwitchListTile(
                title: const Text('Modo Oscuro'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: isDark,
                onChanged: (value) {
                  BookioApp.isDarkModeNotifier.value = value;
                },
              );
            },
          ),
          
          const Divider(),
          _buildSectionTitle('Soporte'),
          _buildListTile(context, 'Centro de Ayuda', Icons.help_outline),
          _buildListTile(context, 'Política de Privacidad', Icons.privacy_tip_outlined),
          
          if (isBusiness) ...[
            const Divider(),
            _buildSectionTitle('Negocio'),
            ListTile(
              leading: const Icon(Icons.remove_red_eye_outlined),
              title: const Text('Ver Perfil (Vista Cliente)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessDetailScreen()));
              },
            ),
          ],
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PendingFeatureWidget(featureName: title)));
      },
    );
  }
}
