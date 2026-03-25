import 'package:flutter/material.dart';
import '../../widgets/pending_feature_widget.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Mis Servicios', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Buscar Servicio')));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildServiceTile(context, "Corte de Barba", "30 min", "\$250", Icons.face_retouching_natural),
          _buildServiceTile(context, "Corte de Cabello", "45 min", "\$350", Icons.content_cut),
          _buildServiceTile(context, "Manicura Spa", "60 min", "\$400", Icons.back_hand),
          _buildServiceTile(context, "Tratamiento Facial", "60 min", "\$650", Icons.spa),
          const SizedBox(height: 80), // Fab space
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: 'services_fab',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Agregar Servicio')));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.add, color: Theme.of(context).cardColor),
        label: Text('Nuevo Servicio', style: TextStyle(color: Theme.of(context).cardColor)),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String name, String duration, String price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            onSelected: (value) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PendingFeatureWidget(featureName: value)));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Editar Servicio',
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'Eliminar Servicio',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}