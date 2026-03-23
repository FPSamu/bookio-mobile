import 'package:flutter/material.dart';
import '../widgets/pending_alert.dart';
import '../widgets/custom_button.dart';
import 'main_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 100, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Bookio',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Iniciar Sesión',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => showPendingAlert(context, 'Autenticación con Supabase'),
                child: const Text('Registrarse'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showPendingAlert(context, 'Autenticación con Supabase'),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Login con Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
