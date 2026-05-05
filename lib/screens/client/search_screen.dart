import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../models/business_model.dart';
import '../../widgets/business_card.dart';
import 'business_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BusinessModel> _results = [];
  bool _isSearching = false;

  String? _selectedType;
  double? _selectedRating;

  void _performSearch() async {
    setState(() => _isSearching = true);
    try {
      final results = await context.read<BusinessProvider>().searchBusinessesWithFilters(
        query: _searchController.text,
        type: _selectedType,
        ratingGte: _selectedRating,
      );
      setState(() => _results = results);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip('BARBERSHOP', 'Barbería', setModalState),
                  _buildTypeChip('SPA', 'Spa', setModalState),
                  _buildTypeChip('SALON', 'Salón', setModalState),
                  _buildTypeChip('RESTAURANT', 'Restaurante', setModalState),
                  _buildTypeChip('MEDICAL', 'Médico', setModalState),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Calificación mínima', style: TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: _selectedRating ?? 0,
                min: 0, max: 5, divisions: 5,
                label: _selectedRating?.toString() ?? '0',
                onChanged: (val) => setModalState(() => _selectedRating = val == 0 ? null : val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () { Navigator.pop(context); _performSearch(); },
                  child: const Text('Aplicar Filtros'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, StateSetter setModalState) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedType == type,
      onSelected: (selected) => setModalState(() => _selectedType = selected ? type : null),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Buscar negocios...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () { _searchController.clear(); _performSearch(); },
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterModal),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty && _selectedType == null
                        ? 'Escribe algo o usa los filtros'
                        : 'No se encontraron resultados',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final business = _results[index];
                    return BusinessCard(
                      business: business,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: business)),
                      ),
                    );
                  },
                ),
    );
  }
}
