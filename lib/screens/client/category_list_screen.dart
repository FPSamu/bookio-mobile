import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/business_card.dart';
import 'business_detail_screen.dart';
import 'search_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final String categoryName;
  final String categoryType;

  const CategoryListScreen({super.key, required this.categoryName, required this.categoryType});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  String _selectedFilter = 'Cerca de mí';

  final List<String> _filters = ['Cerca de mí', 'Mejor calificados', 'Abiertos ahora', 'Precio'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().fetchBusinessesByType(widget.categoryType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary, size: 24),
                      ),
                      Expanded(
                        child: Text(
                          'Buscar en ${widget.categoryName}...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick filters
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) { if (selected) setState(() => _selectedFilter = filter); },
                      backgroundColor: Theme.of(context).cardColor,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Cerca de ti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          Consumer<BusinessProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverToBoxAdapter(
                  child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                );
              }
              if (provider.error != null) {
                return SliverToBoxAdapter(child: Center(child: Text('Error: ${provider.error}')));
              }
              if (provider.businesses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No se encontraron negocios en esta categoría.'),
                  )),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final business = provider.businesses[index];
                    return BusinessCard(
                      business: business,
                      heroTag: 'hero_${business.id}_$index',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: business)),
                      ),
                    );
                  },
                  childCount: provider.businesses.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
