import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidad')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Última actualización: Mayo 2025',
            style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: 20),
          _section(context, '1. Información que recopilamos', '''
Al registrarte en Bookio recopilamos:
• Nombre completo y correo electrónico
• Número de teléfono (opcional)
• Foto de perfil (si inicias sesión con Google)
• Historial de citas y negocios visitados (almacenado en tu dispositivo)'''),

          _section(context, '2. Cómo usamos tu información', '''
Usamos tu información para:
• Crear y gestionar tu cuenta
• Permitirte agendar citas con negocios registrados
• Enviarte recordatorios de tus citas (solo con tu permiso)
• Mejorar la experiencia dentro de la aplicación'''),

          _section(context, '3. Compartir información', '''
No vendemos ni compartimos tu información personal con terceros, excepto:
• Con los negocios en los que reserves citas (nombre y contacto básico)
• Cuando sea requerido por ley
• Con proveedores de servicios técnicos que operan bajo acuerdos de confidencialidad (Firebase, AWS)'''),

          _section(context, '4. Almacenamiento y seguridad', '''
Tu información se almacena en servidores protegidos. Las contraseñas son gestionadas por Firebase Authentication y nunca se almacenan en texto plano. Los datos locales (favoritos, historial) se guardan en tu dispositivo usando SharedPreferences.'''),

          _section(context, '5. Tus derechos', '''
Tienes derecho a:
• Acceder, corregir o eliminar tu información personal
• Revocar permisos de notificaciones en cualquier momento
• Solicitar la eliminación de tu cuenta escribiendo a soporte@bookio.app'''),

          _section(context, '6. Cookies y rastreo', '''
Bookio no utiliza cookies de rastreo publicitario. Únicamente usamos tokens de sesión necesarios para el funcionamiento de la app.'''),

          _section(context, '7. Menores de edad', '''
Bookio no está dirigida a menores de 13 años. No recopilamos intencionalmente información de menores.'''),

          _section(context, '8. Cambios a esta política', '''
Podemos actualizar esta política ocasionalmente. Te notificaremos sobre cambios importantes a través de la aplicación.'''),

          _section(context, '9. Contacto', '''
Para preguntas sobre privacidad:
📧 privacidad@bookio.app
📍 Zapopan, Jalisco, México'''),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(body.trim(), style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7), height: 1.6)),
        ],
      ),
    );
  }
}
