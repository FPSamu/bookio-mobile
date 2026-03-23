import 'package:flutter/material.dart';
import '../main.dart'; // To access global state
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          const SizedBox(height: 32),
          const Divider(),
          
          ValueListenableBuilder<bool>(
            valueListenable: BookioApp.isDarkModeNotifier,
            builder: (context, isDark, _) {
              return SwitchListTile(
                title: const Text('Modo Oscuro'),
                secondary: const Icon(Icons.dark_mode),
                value: isDark,
                onChanged: (value) {
                  BookioApp.isDarkModeNotifier.value = value;
                },
              );
            },
          ),
          
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
}
