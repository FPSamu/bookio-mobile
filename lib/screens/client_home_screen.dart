import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/business_card.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businesses = MockData.businesses;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Negocios'),
      ),
      body: ListView.builder(
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          return BusinessCard(business: businesses[index]);
        },
      ),
    );
  }
}
