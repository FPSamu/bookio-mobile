import 'package:flutter/material.dart';
import '../models/business_model.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback? onTap;
  final String? heroTag;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
    this.heroTag,
  });

  static const Map<String, String> _typeLabels = {
    'BARBERSHOP': 'Barbería',
    'SPA': 'Spa',
    'SALON': 'Salón de Belleza',
    'RESTAURANT': 'Restaurante',
    'MEDICAL': 'Médico',
    'OTHER': 'Otro',
  };

  String get _typeLabel => _typeLabels[business.type] ?? business.type;

  String get _imageUrl =>
      business.photos.isNotEmpty ? business.photos.first : (business.logoUrl ?? '');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(context, cs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageWidget = _imageUrl.isNotEmpty
        ? Image.network(
            _imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.store, color: Colors.grey, size: 32),
          )
        : const Icon(Icons.store, color: Colors.grey, size: 32);

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 90,
        height: 90,
        color: Colors.grey.shade200,
        child: imageWidget,
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: child);
    }
    return child;
  }

  Widget _buildInfo(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          business.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _typeLabel,
          style: TextStyle(
            color: cs.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade500),
            const SizedBox(width: 3),
            Text(
              business.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            Text(
              ' (${business.reviewCount})',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
            ),
            if (business.address != null) ...[
              const Spacer(),
              Icon(Icons.location_on_rounded, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  business.address!,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
