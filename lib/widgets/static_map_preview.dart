import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StaticMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;
  final VoidCallback? onTap;

  const StaticMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 180,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bookio.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 40,
                          height: 44,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red.shade600,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, size: 13, color: Colors.indigo),
                        SizedBox(width: 4),
                        Text('Ver en Mapas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
