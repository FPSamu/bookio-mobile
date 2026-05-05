import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqs = [
    _FaqItem(
      question: '¿Cómo agendo una cita?',
      answer: 'Explora la pantalla de inicio o busca un negocio por categoría. Al entrar al detalle, selecciona un servicio y elige el día y horario disponible. Confirma la reserva y listo — recibirás un código QR de confirmación.',
    ),
    _FaqItem(
      question: '¿Puedo cancelar mi cita?',
      answer: 'Sí. Entra a "Mis Citas", selecciona la cita y toca "Cancelar cita" al final de la pantalla. Solo puedes cancelar citas futuras.',
    ),
    _FaqItem(
      question: '¿Cómo califico un servicio?',
      answer: 'Una vez que tu cita haya pasado, aparecerá en la pestaña "Historial". Si no fue cancelada, verás el botón "Calificar experiencia" para dejar tu reseña.',
    ),
    _FaqItem(
      question: '¿Cómo guardo un negocio en favoritos?',
      answer: 'En la pantalla de detalle del negocio, toca el ícono de corazón en la esquina superior derecha. Lo encontrarás después en la pestaña "Favoritos".',
    ),
    _FaqItem(
      question: '¿El código QR es necesario?',
      answer: 'El QR sirve como comprobante de tu reserva. Muéstralo al llegar al establecimiento para agilizar tu atención.',
    ),
    _FaqItem(
      question: '¿Cómo cambio mi información de perfil?',
      answer: 'Ve a Perfil → Editar Perfil. Puedes actualizar tu nombre y número de teléfono. El correo electrónico no es editable.',
    ),
    _FaqItem(
      question: '¿Bookio cobra alguna comisión?',
      answer: 'Bookio es una plataforma gratuita para usuarios. Los precios que ves son los que cobra directamente el negocio.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¿En qué podemos ayudarte?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Respuestas rápidas a las preguntas más frecuentes.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Preguntas frecuentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 12),

          ..._faqs.map((faq) => _FaqTile(faq: faq)),

          const SizedBox(height: 24),

          // Contact card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Icon(Icons.mail_outline_rounded, color: cs.secondary, size: 32),
                const SizedBox(height: 12),
                Text('¿No encontraste tu respuesta?', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(height: 6),
                Text('soporte@bookio.app', style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Respondemos en menos de 24 horas.', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _FaqItem faq;
  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(faq.question, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface)),
        iconColor: cs.secondary,
        collapsedIconColor: cs.onSurface.withValues(alpha: 0.4),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Text(faq.answer, style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7), height: 1.5)),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
