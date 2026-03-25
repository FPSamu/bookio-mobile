import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../booking_screen.dart';
import '../../widgets/pending_feature_widget.dart';

class BusinessDetailScreen extends StatelessWidget {
  const BusinessDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    business: Business(
                      id: 1,
                      name: 'Serenity Spa & Wellness',
                      address: '123 Wellness Street, Downtown District',
                      category: 'Spa',
                      imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=400',
                      services: ['Corte de Cabello', 'Tinte', 'Manicura'],
                    ),
                    serviceName: 'Deep Tissue Massage',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 18, color: Theme.of(context).cardColor),
                const SizedBox(width: 8),
                Text(
                  'Book Appointment',
                  style: TextStyle(
                    color: Theme.of(context).cardColor, 
                    fontSize: 16, 
                    fontWeight: FontWeight.w600
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: Text('Serenity Spa', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Agregar a Favoritos')));
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    child: const Center(
                      child: Text("Spa Interior Photo", style: TextStyle(color: Colors.black45)),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "1/5",
                        style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Serenity Spa & Wellness',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.grey.shade400, size: 16),
                          Icon(Icons.star, color: Colors.grey.shade400, size: 16),
                          Icon(Icons.star, color: Colors.grey.shade400, size: 16),
                          Icon(Icons.star, color: Colors.grey.shade400, size: 16),
                          Icon(Icons.star, color: Colors.grey.shade400, size: 16),
                          const SizedBox(width: 4),
                          const Text("4.9", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Luxury spa • Massage therapy',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text('Downtown • 0.8 km away', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text('Open until 9:00 PM', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text('Popular Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _serviceItem(context, 'Swedish Massage', '60 minutes • Relaxation', '\$89'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                  _serviceItem(context, 'Facial Treatment', '45 minutes • Anti-aging', '\$65'),
                  const SizedBox(height: 32),

                  Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Text(
                    'Experience ultimate relaxation at our luxury spa. We offer a full range of therapeutic treatments in a serene environment designed to restore your mind and body.',
                    style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews (127)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Ver todas las Reseñas')));
                        },
                        child: Text('See all', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Sarah M.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 8),
                                Row(
                                  children: List.generate(5, (index) => Icon(Icons.star, size: 14, color: Colors.grey.shade400)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Amazing experience! The massage was incredibly relaxing and the staff was so professional.',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Mapa Completo')));
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Center(
                        child: Text('Interactive Map', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '123 Wellness Street, Downtown District',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  Text('Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _hoursRow(context, 'Monday - Friday', '9:00 AM - 9:00 PM'),
                  const SizedBox(height: 8),
                  _hoursRow(context, 'Saturday', '8:00 AM - 10:00 PM'),
                  const SizedBox(height: 8),
                  _hoursRow(context, 'Sunday', '10:00 AM - 8:00 PM'),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceItem(BuildContext context, String title, String subtitle, String price) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingScreen(
              business: Business(
                id: 1,
                name: 'Serenity Spa & Wellness',
                address: '123 Wellness Street, Downtown District',
                category: 'Spa',
                imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=400',
                services: ['Corte de Cabello', 'Tinte', 'Manicura'],
              ),
              serviceName: title,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(price, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  Widget _hoursRow(BuildContext context, String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        Text(hours, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}