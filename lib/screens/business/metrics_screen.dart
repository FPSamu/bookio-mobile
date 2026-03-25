import 'package:flutter/material.dart';
import '../../widgets/pending_feature_widget.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurface, size: 20),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Filtro de Fechas')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen de Marzo 2025",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(context, "Citas Totales", "124", Icons.calendar_month, true),
                _buildStatCard(context, "Ingresos Est.", "\$12.4k", Icons.account_balance_wallet, true),
                _buildStatCard(context, "Nuevos Clientes", "28", Icons.person_add, false),
                _buildStatCard(context, "Cancelaciones", "4", Icons.cancel_outlined, false),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rendimiento Semanal",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingFeatureWidget(featureName: 'Reporte Completo')));
                  },
                  child: Text("Ver detalle", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMockChart(context),
            
            const SizedBox(height: 32),
            
            Text(
              "Servicios Populares",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            _buildPopularServiceItem(context, "Corte de Cabello", 65, 0.8),
            _buildPopularServiceItem(context, "Corte de Barba", 42, 0.5),
            _buildPopularServiceItem(context, "Tinte Premium", 17, 0.2),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, bool highlighted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: highlighted ? null : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: highlighted ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: highlighted ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: highlighted ? Colors.white : Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: highlighted ? Colors.white60 : Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPopularServiceItem(BuildContext context, String name, int count, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              Text("$count citas", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              color: Theme.of(context).colorScheme.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockChart(BuildContext context) {
    final List<double> values = [0.4, 0.7, 0.5, 0.9, 0.6, 1.0, 0.8];
    final List<String> days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 120 * values[index],
                decoration: BoxDecoration(
                  color: index == 5 ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(days[index], style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }
}