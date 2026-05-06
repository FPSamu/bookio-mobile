import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../models/business_model.dart';
import '../../widgets/pending_feature_widget.dart';
import 'add_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).fetchMyBusinessData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final business = provider.myBusiness;
    final services = business?.services ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Servicios', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        elevation: 0,
        centerTitle: true,
      ),
      body: services.isEmpty
          ? Center(
              child: Text(
                'No has agregado servicios.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final s = services[index];
                return _buildServiceTile(context, s);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'services_fab',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddServiceScreen())).then((_) {
            provider.fetchMyBusinessData();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.add, color: Theme.of(context).cardColor),
        label: Text('Nuevo Servicio', style: TextStyle(color: Theme.of(context).cardColor)),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, ServiceModel service) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              image: service.photoUrl != null
                  ? DecorationImage(image: NetworkImage(service.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: service.photoUrl == null
                ? Icon(Icons.spa, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 24)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text('${service.durationMinutes} min', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Text('\$${service.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            onSelected: (value) {
              if (value == 'Editar Servicio') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddServiceScreen(service: service)),
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PendingFeatureWidget(featureName: value)));
              }
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