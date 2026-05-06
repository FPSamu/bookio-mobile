import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/pending_feature_widget.dart';
import 'qr_scanner_screen.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).fetchMyMetrics(
        month: _selectedMonth,
        year: _selectedYear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessProvider>(context);
    final metrics = provider.myMetrics;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Confirmar Cita (Escanear)',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QRScannerScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: metrics == null 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => provider.fetchMyMetrics(month: _selectedMonth, year: _selectedYear),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Resumen de Actividad",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      _buildMonthPicker(),
                    ],
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
                      _buildStatCard(context, "Citas Totales", "${metrics['totalAppointments'] ?? 0}", Icons.calendar_month, true),
                      _buildStatCard(context, "Ingresos Est.", "\$${metrics['totalRevenue'] ?? 0}", Icons.account_balance_wallet, true),
                      _buildStatCard(context, "Nuevos Clientes", "${metrics['newClients'] ?? 0}", Icons.person_add, false),
                      _buildStatCard(context, "Cancelaciones", "${metrics['cancellations'] ?? 0}", Icons.cancel_outlined, false),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    "Rendimiento Semanal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  _buildChart(context, metrics['weeklyPerformance']),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    "Servicios Populares",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  if (metrics['popularServices'] != null)
                    ...(metrics['popularServices'] as List).map((s) => _buildPopularServiceItem(
                      context, 
                      s['name'], 
                      s['count'], 
                      (s['count'] / (metrics['totalAppointments'] > 0 ? metrics['totalAppointments'] : 1)).toDouble(),
                    )),
                  
                  const SizedBox(height: 40),
                ],
              ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: highlighted ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 24),
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

  Widget _buildChart(BuildContext context, dynamic weeklyData) {
    final List dataList = List.from((weeklyData as List?) ?? []);
    
    // Sort data: Monday (1) to Saturday (6), then Sunday (0)
    dataList.sort((a, b) {
      int dayA = a['day'] as int;
      int dayB = b['day'] as int;
      // Convert Sunday (0) to 7 for sorting purposes so it comes last
      int sortA = dayA == 0 ? 7 : dayA;
      int sortB = dayB == 0 ? 7 : dayB;
      return sortA.compareTo(sortB);
    });

    final List<double> values = dataList.map((v) => (v['count'] as num).toDouble()).toList();
    while (values.length < 7) {
      values.add(0.0);
    }
    
    final maxVal = values.fold<double>(0, (max, v) => v > max ? v : max);
    final dayNames = ['', 'L', 'M', 'M', 'J', 'V', 'S', 'D']; // Index matches sort value
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(dataList.length, (index) {
          final barHeight = maxVal > 0 ? (values[index] / maxVal) : 0.0;
          final dayNum = dataList[index]['day'] as int;
          final sortVal = dayNum == 0 ? 7 : dayNum;
          final label = dayNames[sortVal];
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 24,
                      height: 100 * barHeight,
                      decoration: BoxDecoration(
                        color: barHeight > 0.8 ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthPicker() {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonth,
          isDense: true,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(months[i]))),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              _fetchData();
            }
          },
        ),
      ),
    );
  }
}