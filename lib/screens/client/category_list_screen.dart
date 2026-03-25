import 'package:flutter/material.dart';
import 'business_detail_screen.dart'; // Importa la pantalla de arriba

class CategoryListScreen extends StatelessWidget {
  final String categoryName;

  const CategoryListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text(
          categoryName, // Dirá "Spa", "Barbería", etc.
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5, // Cambia esto por la longitud de tu lista real (ej. negocios.length)
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // AL HACER CLIC EN EL NEGOCIO, VAMOS AL DETALLE
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusinessDetailScreen(), // Pasa el objeto business aquí
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Serenity Spa & Wellness", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("Centro • 0.8 km", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            const Text("4.9", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}