import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/business_model.dart';
import '../../models/appointment_model.dart';
import '../../services/business_service.dart';
import '../../providers/business_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'booking_screen.dart';
import '../../services/storage_service.dart';
import '../../widgets/static_map_preview.dart';

class BusinessDetailScreen extends StatefulWidget {
  final BusinessModel business;
  const BusinessDetailScreen({super.key, required this.business});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  List<ServiceModel> _services = [];
  List<Map<String, dynamic>> _schedule = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingServices = true;
  bool _isLoadingSchedule = true;
  bool _isLoadingReviews = true;
  static const _dayNames = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  static const _dayNamesFull = [
    'Domingo',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _fetchSchedule();
    _fetchReviews();
    StorageService.instance.addRecentBusiness(widget.business);
  }

  Future<void> _launchMaps() async {
    final lat = widget.business.latitude;
    final lng = widget.business.longitude;
    final address = widget.business.address;
    Uri url;
    if (lat != null && lng != null) {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else if (address != null && address.isNotEmpty) {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay ubicación disponible')),
        );
      return;
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir los mapas')),
        );
    }
  }

  Future<void> _launchPhone() async {
    final phone = widget.business.phone;
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (!await launchUrl(url)) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el marcador')),
        );
    }
  }

  void _openImageGallery(BuildContext context) {
    final images = widget.business.photos.isNotEmpty
        ? widget.business.photos
        : (widget.business.logoUrl != null
              ? [widget.business.logoUrl!]
              : <String>[]);
    if (images.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) => InteractiveViewer(
                child: Image.network(images[index], fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchServices() async {
    try {
      final services = await BusinessService.instance.getBusinessServices(
        widget.business.id,
      );
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
    } catch (_) {
      setState(() => _isLoadingServices = false);
    }
  }

  Future<void> _fetchSchedule() async {
    try {
      final schedule = await BusinessService.instance.getBusinessSchedule(
        widget.business.id,
      );
      setState(() {
        _schedule = schedule;
        _isLoadingSchedule = false;
      });
    } catch (_) {
      setState(() => _isLoadingSchedule = false);
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await BusinessService.instance.getBusinessReviews(
        widget.business.id,
      );
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (_) {
      setState(() => _isLoadingReviews = false);
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  List<_ScheduleGroup> _buildScheduleGroups() {
    if (_schedule.isEmpty) return [];
    final groups = <_ScheduleGroup>[];
    for (final entry in _schedule) {
      final day = entry['day_of_week'] as int;
      final start = entry['start_time'] as String? ?? '';
      final end = entry['end_time'] as String? ?? '';
      final existing = groups.where((g) => g.start == start && g.end == end);
      if (existing.isNotEmpty) {
        existing.first.days.add(day);
      } else {
        groups.add(_ScheduleGroup(days: [day], start: start, end: end));
      }
    }
    return groups;
  }

  String _groupDayLabel(_ScheduleGroup group) {
    if (group.days.length == 1) return _dayNamesFull[group.days.first];
    final sorted = List<int>.from(group.days)..sort();
    bool consecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) {
        consecutive = false;
        break;
      }
    }
    if (consecutive && sorted.length > 2) {
      return '${_dayNames[sorted.first]} - ${_dayNames[sorted.last]}';
    }
    return sorted.map((d) => _dayNames[d]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── PHOTO HEADER ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).cardColor.withValues(alpha: 0.85),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Consumer<BusinessProvider>(
                builder: (context, bp, _) {
                  final fav = bp.isFavorite(widget.business.id);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).cardColor.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? Colors.redAccent : cs.onSurface,
                        ),
                        onPressed: () => bp.toggleFavorite(
                          widget.business.id,
                          widget.business,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: cs.surfaceContainerHighest,
                    child: widget.business.photos.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _openImageGallery(context),
                            child: Image.network(
                              widget.business.photos.first,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.store,
                              size: 64,
                              color: cs.onSurface.withValues(alpha: 0.2),
                            ),
                          ),
                  ),
                  if (widget.business.photos.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${widget.business.photos.length} Fotos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── INFO PRINCIPAL ────────────────────────────────────
                  _sectionCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.business.logoUrl != null) ...[
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  widget.business.logoUrl!,
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.business.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.secondaryContainer.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.business.type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Rating row
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < widget.business.averageRating.round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Colors.amber.shade500,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.business.averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              ' (${widget.business.reviewCount} reseñas)',
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                        if (widget.business.address != null ||
                            widget.business.phone != null) ...[
                          const SizedBox(height: 16),
                          Divider(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (widget.business.address != null)
                          _infoTile(
                            context,
                            Icons.location_on_outlined,
                            widget.business.address!,
                            cs,
                          ),
                        if (widget.business.phone != null) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _launchPhone,
                            child: _infoTile(
                              context,
                              Icons.phone_outlined,
                              widget.business.phone!,
                              cs,
                              color: cs.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── SERVICIOS ─────────────────────────────────────────
                  _sectionHeader(
                    context,
                    'Servicios',
                    Icons.design_services_outlined,
                    cs,
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingServices)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_services.isEmpty)
                    _emptyState(context, 'No hay servicios disponibles', cs)
                  else
                    ..._services.map(
                      (s) => _serviceItem(context, s, cs, isDark),
                    ),
                  const SizedBox(height: 16),

                  // ── UBICACIÓN ─────────────────────────────────────────
                  _sectionHeader(
                    context,
                    'Ubicación',
                    Icons.location_on_outlined,
                    cs,
                  ),
                  const SizedBox(height: 10),
                  _sectionCard(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.business.latitude != null &&
                            widget.business.longitude != null)
                          StaticMapPreview(
                            latitude: widget.business.latitude!,
                            longitude: widget.business.longitude!,
                            height: 160,
                            onTap: _launchMaps,
                          )
                        else
                          GestureDetector(
                            onTap: _launchMaps,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Abrir en Mapas',
                                      style: TextStyle(
                                        color: cs.secondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (widget.business.address != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.business.address!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── HORARIOS ──────────────────────────────────────────
                  _sectionHeader(
                    context,
                    'Horarios',
                    Icons.access_time_rounded,
                    cs,
                  ),
                  const SizedBox(height: 10),
                  _sectionCard(
                    context,
                    child: _isLoadingSchedule
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _schedule.isEmpty
                        ? _emptyState(
                            context,
                            'No hay horarios disponibles',
                            cs,
                          )
                        : Column(
                            children: _buildScheduleGroups()
                                .map(
                                  (g) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: cs.secondary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              _groupDayLabel(g),
                                              style: TextStyle(
                                                color: cs.onSurface.withValues(
                                                  alpha: 0.7,
                                                ),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cs.secondaryContainer
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${_formatTime(g.start)} - ${_formatTime(g.end)}',
                                            style: TextStyle(
                                              color: cs.secondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // ── RESEÑAS ───────────────────────────────────────────
                  _sectionHeader(
                    context,
                    'Reseñas',
                    Icons.star_outline_rounded,
                    cs,
                  ),
                  const SizedBox(height: 10),
                  if (_isLoadingReviews)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_reviews.isEmpty)
                    _sectionCard(
                      context,
                      child: _emptyState(context, 'Aún no hay reseñas', cs),
                    )
                  else
                    ..._reviews
                        .take(10)
                        .map((r) => _reviewItem(context, r, cs, isDark)),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    ColorScheme cs,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String text,
    ColorScheme cs, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? cs.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color ?? cs.onSurface.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, String message, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _serviceItem(
    BuildContext context,
    ServiceModel service,
    ColorScheme cs,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                BookingScreen(business: widget.business, service: service),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.spa_outlined, size: 20, color: cs.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 13,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.durationMinutes} min',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewItem(
    BuildContext context,
    Map<String, dynamic> review,
    ColorScheme cs,
    bool isDark,
  ) {
    final score = (review['score'] as num?)?.toDouble() ?? 0;
    final comment = review['comment'] as String?;
    final clientName = (review['client']?['name'] ?? 'Cliente') as String;
    final dateStr = (review['createdAt'] ?? review['created_at']) as String?;
    String dateFormatted = '';
    if (dateStr != null) {
      final date = DateTime.tryParse(dateStr);
      if (date != null)
        dateFormatted = DateFormat('d MMM yyyy', 'es').format(date.toLocal());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clientName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
              if (dateFormatted.isNotEmpty)
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < score ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: Colors.amber.shade500,
              ),
            ),
          ),
          if (comment != null && comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleGroup {
  final List<int> days;
  final String start;
  final String end;
  _ScheduleGroup({required this.days, required this.start, required this.end});
}
