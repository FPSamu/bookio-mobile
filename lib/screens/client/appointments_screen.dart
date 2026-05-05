import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/storage_service.dart';
import 'appointment_detail_screen.dart';
import '../main_navigation.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            labelColor: cs.secondary,
            unselectedLabelColor: cs.onSurface.withValues(alpha: 0.45),
            indicatorColor: cs.secondary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            tabs: const [Tab(text: 'Próximas'), Tab(text: 'Historial')],
          ),
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.error != null) return Center(child: Text('Error: ${provider.error}'));

          final history = List<AppointmentModel>.from(provider.pastAppointments)
            ..sort((a, b) => b.startDatetime.compareTo(a.startDatetime));

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(provider.upcomingAppointments, isUpcoming: true),
              _buildList(history, isUpcoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> list, {required bool isUpcoming}) {
    if (list.isEmpty) return _buildEmptyState(isUpcoming);
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildCard(context, list[index], isUpcoming),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUpcoming ? Icons.calendar_today_rounded : Icons.history_rounded,
                size: 64,
                color: cs.secondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming ? 'Sin citas próximas' : 'Sin historial',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isUpcoming
                    ? '¡Explora lugares increíbles y agenda tu primera cita!'
                    : 'Cuando asistas a tus citas, aparecerán aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation(userRole: 'CLIENT', initialIndex: 0)),
                      (r) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    minimumSize: Size.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Explorar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AppointmentModel apt, bool isUpcoming) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localStart = apt.startDatetime.toLocal();
    final dateFormatted = DateFormat("EEEE, d 'de' MMMM", 'es').format(localStart);
    final timeFormatted = DateFormat('h:mm a').format(localStart);

    final isCancelled = apt.status.toUpperCase() == 'CANCELLED';
    final localRating = StorageService.instance.getAppointmentRating(apt.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AppointmentDetailScreen(appointment: apt)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _cap(dateFormatted),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface),
                  ),
                  _statusBadge(context, apt.status),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: cs.surfaceContainerHighest,
                      image: apt.business?.logoUrl != null
                          ? DecorationImage(image: NetworkImage(apt.business!.logoUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: apt.business?.logoUrl == null
                        ? Icon(Icons.store_rounded, color: cs.onSurface.withValues(alpha: 0.3))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.business?.name ?? 'Negocio',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: cs.onSurface, letterSpacing: -0.4),
                        ),
                        const SizedBox(height: 4),
                        Text(apt.service?.name ?? 'Servicio', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Icon(Icons.access_time_rounded, size: 15, color: cs.secondary),
                        const SizedBox(height: 3),
                        Text(timeFormatted, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: cs.onSurface)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isUpcoming) ...[
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.all(12),
                child: isCancelled
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 15, color: cs.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(width: 6),
                          Text('Cita cancelada', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4))),
                        ],
                      )
                    : localRating != null
                        ? _ratingDisplay(context, localRating)
                        : _rateButton(context, apt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ratingDisplay(BuildContext context, double rating) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(5, (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 20,
          color: Colors.amber.shade500,
        )),
        const SizedBox(width: 8),
        Text(rating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _rateButton(BuildContext context, AppointmentModel apt) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showRatingDialog(context, apt),
        icon: const Icon(Icons.star_outline_rounded, size: 18),
        label: const Text('Calificar experiencia', style: TextStyle(fontWeight: FontWeight.w600)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.amber.shade700,
          backgroundColor: Colors.amber.shade50.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, AppointmentModel apt) {
    double selectedRating = 0;
    final reviewController = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Califica tu experiencia', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(apt.business?.name ?? 'Negocio', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setDialogState(() => selectedRating = i + 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: Colors.amber.shade500,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe tu reseña (opcional)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: selectedRating == 0 ? null : () async {
                final appointmentProvider = context.read<AppointmentProvider>();
                final businessProvider = context.read<BusinessProvider>();
                final reviewText = reviewController.text.trim().isEmpty ? null : reviewController.text.trim();
                try {
                  await appointmentProvider.submitReview(
                    appointmentId: apt.id,
                    businessId: apt.businessId,
                    clientId: apt.clientId,
                    score: selectedRating,
                    comment: reviewText,
                  );
                  await StorageService.instance.saveAppointmentRating(apt.id, selectedRating, review: reviewText);
                  if (ctx.mounted) Navigator.pop(ctx);
                  // Refresh business rating in the background
                  businessProvider.refreshBusiness(apt.businessId);
                  if (context.mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('¡Gracias por tu reseña!'),
                      backgroundColor: Colors.amber.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Enviar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg; Color fg;
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'COMPLETED':
        bg = isDark ? const Color(0xFF14532D).withValues(alpha: 0.6) : const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        break;
      case 'PENDING':
        bg = isDark ? const Color(0xFF78350F).withValues(alpha: 0.6) : const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'CANCELLED':
        bg = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF3F4F6);
        fg = isDark ? Colors.white54 : const Color(0xFF6B7280);
        break;
      default:
        bg = isDark ? const Color(0xFF1E3A5F).withValues(alpha: 0.6) : const Color(0xFFEFF6FF);
        fg = const Color(0xFF3B82F6);
    }
    final label = {
      'CONFIRMED': 'Confirmada', 'COMPLETED': 'Completada',
      'PENDING': 'Pendiente', 'CANCELLED': 'Cancelada',
    }[status.toUpperCase()] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  String _cap(String text) => text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}
