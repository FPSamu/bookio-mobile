import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/business_provider.dart';
import 'package:intl/intl.dart';
import 'category_list_screen.dart';
import '../../widgets/pending_feature_widget.dart';
import 'appointments_screen.dart';
import 'search_screen.dart';
import 'business_detail_screen.dart';
import 'appointment_detail_screen.dart';
import '../../services/storage_service.dart';

class ClientExploreScreen extends StatefulWidget {
  const ClientExploreScreen({super.key});

  @override
  State<ClientExploreScreen> createState() => _ClientExploreScreenState();
}

class _ClientExploreScreenState extends State<ClientExploreScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
      context.read<BusinessProvider>().fetchBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Bookio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              child: IconButton(
                icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Notificaciones')));
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Upcoming Section
            Consumer<AppointmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final upcoming = provider.upcomingAppointments;
                if (upcoming.isEmpty) {
                  return const SizedBox.shrink(); // Hide if empty
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Próximas Citas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
                            },
                            child: Text(
                              'Ver todas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final nextApt = upcoming.first;
                        final localStart = nextApt.startDatetime.toLocal();
                        final dateFormatted = DateFormat("EEEE, d 'de' MMMM", "es").format(localStart);
                        final timeFormatted = DateFormat("h:mm a").format(localStart);
                        final dateCap = "${dateFormatted[0].toUpperCase()}${dateFormatted.substring(1)}";

                        return _upcomingCard(
                          context,
                          Icons.calendar_today_rounded,
                          nextApt.business?.name ?? nextApt.service?.name ?? "Cita",
                          "$dateCap, $timeFormatted",
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 12),
                      Text(
                        "Buscar restaurantes, spas, médicos...",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),


            _buildCategories(context),
            const SizedBox(height: 24),
            _buildRecentBusinesses(context),
            const SizedBox(height: 24),            // Recomendados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Recomendados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<BusinessProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.recommendedBusinesses.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text("No hay recomendaciones por ahora.", style: TextStyle(color: Colors.grey)),
                  );
                }
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: provider.recommendedBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = provider.recommendedBusinesses[index];
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: business)));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      image: business.photos.isNotEmpty 
                                          ? DecorationImage(image: NetworkImage(business.photos.first), fit: BoxFit.cover)
                                          : null,
                                    ),
                                    child: business.photos.isEmpty ? const Icon(Icons.store, color: Colors.grey) : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(business.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 14, color: Colors.orange.shade400),
                                          const SizedBox(width: 4),
                                          Text(business.averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _upcomingCard(BuildContext context, IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          final provider = context.read<AppointmentProvider>();
          final upcoming = provider.upcomingAppointments;
          if (upcoming.isNotEmpty) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentDetailScreen(appointment: upcoming.first)));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Text(
                  "Confirmada",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'name': 'Barberías', 'icon': Icons.content_cut, 'type': 'BARBERSHOP'},
      {'name': 'Spas', 'icon': Icons.spa, 'type': 'SPA'},
      {'name': 'Salones', 'icon': Icons.face, 'type': 'SALON'},
      {'name': 'Restaurantes', 'icon': Icons.restaurant, 'type': 'RESTAURANT'},
      {'name': 'Médicos', 'icon': Icons.local_hospital, 'type': 'MEDICAL'},
      {'name': 'Otros', 'icon': Icons.category, 'type': 'OTHER'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Categorías',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryListScreen(categoryName: cat['name'] as String, categoryType: cat['type'] as String)));
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat['icon'] as IconData, color: Theme.of(context).colorScheme.primary, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBusinesses(BuildContext context) {
    final recent = StorageService.instance.getRecentBusinesses();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Vistos Recientemente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recent.length,
            itemBuilder: (context, index) {
              final b = recent[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessDetailScreen(business: b)));
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: b.photos.isNotEmpty ? DecorationImage(
                            image: NetworkImage(b.photos.first),
                            fit: BoxFit.cover,
                          ) : null,
                          color: Colors.grey.shade300,
                        ),
                        child: b.photos.isEmpty ? const Center(child: Icon(Icons.store, color: Colors.grey)) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                                const SizedBox(width: 2),
                                Text(b.averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}