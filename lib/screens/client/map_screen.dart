import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import 'business_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Default center: Guadalajara, México
  static const LatLng _defaultCenter = LatLng(20.6597, -103.3496);

  BusinessModel? _selectedBusiness;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  double _radiusKm = 5.0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 14.0);
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  void _centerMap() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 14.0);
    } else {
      _getCurrentLocation();
    }
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom;
    final center = _mapController.camera.center;
    _mapController.move(center, zoom + 1);
  }

  void _zoomOut() {
    final zoom = _mapController.camera.zoom;
    final center = _mapController.camera.center;
    _mapController.move(center, zoom - 1);
  }

  static const Map<String, String> _typeLabels = {
    'BARBERSHOP': 'Barbería',
    'SPA': 'Spa',
    'SALON': 'Salón de Belleza',
    'RESTAURANT': 'Restaurante',
    'MEDICAL': 'Médico',
    'OTHER': 'Otro',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<BusinessProvider>(
        builder: (context, provider, _) {
          final businesses = provider.businesses.where((b) {
            if (b.latitude == null || b.longitude == null) return false;
            if (_currentLocation != null) {
              final distanceMeters = Geolocator.distanceBetween(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
                b.latitude!,
                b.longitude!,
              );
              return distanceMeters <= _radiusKm * 1000;
            }
            return true;
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: businesses.isNotEmpty
                      ? LatLng(businesses.first.latitude!, businesses.first.longitude!)
                      : _defaultCenter,
                  initialZoom: 13.0,
                  onTap: (_, _) => setState(() => _selectedBusiness = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bookio.app',
                  ),
                  MarkerLayer(
                    markers: [
                      ...businesses.map((b) {
                        final isSelected = _selectedBusiness?.id == b.id;
                        return Marker(
                          point: LatLng(b.latitude!, b.longitude!),
                          width: isSelected ? 52 : 44,
                          height: isSelected ? 52 : 44,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedBusiness = b);
                              _mapController.move(LatLng(b.latitude!, b.longitude!), 15);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? cs.primary : cs.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: Icon(
                                _typeIcon(b.type),
                                color: Colors.white,
                                size: isSelected ? 26 : 22,
                              ),
                            ),
                          ),
                        );
                      }),
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 64,
                          height: 64,
                          child: AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, _) => Stack(
                              alignment: Alignment.center,
                              children: [
                                // anillo pulsante
                                Container(
                                  width: 64 * _pulseAnim.value,
                                  height: 64 * _pulseAnim.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.withValues(alpha: (1 - _pulseAnim.value) * 0.5),
                                  ),
                                ),
                                // punto central
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2),
                                    ],
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Top search bar overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.map_rounded, color: cs.primary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Negocios cercanos',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                '${businesses.length} en rango',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.secondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_currentLocation != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              Text('Radio: ${_radiusKm.toInt()} km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: cs.onSurface)),
                              Expanded(
                                child: Slider(
                                  value: _radiusKm,
                                  min: 1,
                                  max: 50,
                                  divisions: 49,
                                  activeColor: cs.primary,
                                  onChanged: (val) => setState(() {
                                    _radiusKm = val;
                                    _selectedBusiness = null; // Reset selection on filter change
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Selected business card
              if (_selectedBusiness != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: _BusinessBottomCard(
                    business: _selectedBusiness!,
                    typeLabel: _typeLabels[_selectedBusiness!.type] ?? _selectedBusiness!.type,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: _selectedBusiness!)),
                      );
                    },
                    onClose: () => setState(() => _selectedBusiness = null),
                  ),
                ),

              // No-location fallback message
              if (businesses.isEmpty && !provider.isLoading)
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off_rounded, size: 48, color: cs.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          'Sin negocios en el mapa',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Los negocios aparecerán aquí cuando tengan ubicación registrada.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
              // Map Controls (Zoom & Location)
              Positioned(
                bottom: _selectedBusiness != null ? 140 : 24,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_fab',
                      onPressed: _zoomIn,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor: cs.onSurface,
                      elevation: 4,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_fab',
                      onPressed: _zoomOut,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor: cs.onSurface,
                      elevation: 4,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'center_map_fab',
                      onPressed: _centerMap,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor: cs.primary,
                      elevation: 4,
                      child: _isLoadingLocation
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'BARBERSHOP': return Icons.content_cut;
      case 'SPA': return Icons.spa;
      case 'SALON': return Icons.face;
      case 'RESTAURANT': return Icons.restaurant;
      case 'MEDICAL': return Icons.local_hospital;
      default: return Icons.store;
    }
  }
}

class _BusinessBottomCard extends StatelessWidget {
  final BusinessModel business;
  final String typeLabel;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _BusinessBottomCard({
    required this.business,
    required this.typeLabel,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  child: business.photos.isNotEmpty
                      ? Image.network(business.photos.first, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.store, color: Colors.grey))
                      : const Icon(Icons.store, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(business.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(typeLabel, style: TextStyle(fontSize: 12, color: cs.secondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade500),
                        const SizedBox(width: 3),
                        Text(
                          business.averageRating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                        Text(
                          ' (${business.reviewCount})',
                          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.45)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.secondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
