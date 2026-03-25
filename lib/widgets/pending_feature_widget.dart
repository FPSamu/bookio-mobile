import 'package:flutter/material.dart';

class PendingFeatureWidget extends StatelessWidget {
  final String featureName;
  final bool isTab;

  const PendingFeatureWidget({
    super.key, 
    required this.featureName, 
    this.isTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
        elevation: 0,
        automaticallyImplyLeading: !isTab,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 80,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Funcionalidad Pendiente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'La pantalla/función "$featureName" aún no ha sido implementada en este prototipo.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!isTab)
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Volver'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
