import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../screens/business_detail_screen.dart';

class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.store),
          ),
        ),
        title: Text(business.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${business.category}\n${business.address}'),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessDetailScreen(business: business),
            ),
          );
        },
      ),
    );
  }
}
