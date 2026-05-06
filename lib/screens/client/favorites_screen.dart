import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/business_card.dart';
import 'business_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, _) {
          if (provider.favoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final favs = provider.favoriteBusinesses;
          if (favs.isEmpty) {
            return Center(
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
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchFavorites(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    if (context.mounted) provider.fetchFavorites();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
