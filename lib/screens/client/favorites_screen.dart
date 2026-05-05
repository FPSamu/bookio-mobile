import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../widgets/business_card.dart';
import 'business_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favs = StorageService.instance.getFavorites();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: favs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: cs.onSurface.withValues(alpha: 0.15)),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes favoritos',
                    style: TextStyle(fontSize: 18, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guarda los lugares que te gusten\npara encontrarlos más rápido.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              itemCount: favs.length,
              itemBuilder: (context, index) {
                final business = favs[index];
                return BusinessCard(
                  business: business,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: business)),
                    );
                    setState(() {}); // refresh in case it was unfavorited
                  },
                );
              },
            ),
    );
  }
}
