import 'package:flutter/material.dart';
import '../widgets/pending_feature_widget.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos un esquema de color profesional
    const Color primaryColor = Colors.indigo;
    const Color onPrimaryColor = Colors.white;
    const Color surfaceColor = Colors.white;
    final Color? secondaryTextColor = Colors.grey[600];
    const Color dividerColor = Colors.grey;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido verticalmente si es posible
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los widgets horizontamente
            children: [
              // Logo 'Bookio' Centrado y Grande
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 64.0, bottom: 48.0),
                  child: Text(
                    'Bookio',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48, // Tamaño grande
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0, // Espaciado profesional
                      color: Colors.black, // O primaryColor para un toque de color
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),

              // Sección de Campos de Texto
              _buildTextFieldGroup(
                label: 'Correo Electrónico',
                hint: 'ejemplo@correo.com',
                icon: Icons.email_outlined,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 24),
              _buildTextFieldGroup(
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscureText: true,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingFeatureWidget(
                          featureName: 'Recuperar Contraseña'),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Botón de Iniciar Sesión (Sólido)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Acción solicitada por el usuario: Login dice Pendiente
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PendingFeatureWidget(
                            featureName: 'Iniciar Sesión'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimaryColor,
                    elevation: 2, // Pequeña sombra profesional
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),

              // Divisor Centrado
              Row(
                children: [
                  Expanded(child: Divider(color: dividerColor.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: dividerColor.withOpacity(0.3))),
                ],
              ),
              
              const SizedBox(height: 32),

              // Botón de Google Centrado con Imagen
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PendingFeatureWidget(
                          featureName: 'Login con Google'),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: dividerColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido del botón
                    children: [
                      // Imagen Placeholder del logo de Google
                      // En una app real, usarías Image.asset('assets/google_logo.png')
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/3840px-Google_%22G%22_logo.svg.png',
                        height: 24, // Tamaño profesional de icono
                        width: 24,
                      ),
                      const SizedBox(width: 16), // Espacio profesional
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Enlace de Registro Centrado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterSelectionScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para agrupar etiqueta y campo de texto con estilo profesional
  Widget _buildTextFieldGroup({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Etiquetas alineadas a la izquierda
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[50], // Fondo sutil
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18, // Ligeramente más alto para un toque profesional
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}