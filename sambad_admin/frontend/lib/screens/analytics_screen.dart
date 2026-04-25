import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  Map<String, dynamic> _data = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() { _loading = true; _error = null; });
    try {
      _data = await ApiService().fetchDashboardAnalytics();
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Failed: $_error'),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _loadAnalytics, icon: const Icon(Icons.refresh), label: const Text('Retry')),
          ],
        ),
      );
    }

    final totalUsers = (_data['totalUsers'] ?? 0).toDouble();
    final totalMessages = (_data['totalMessages'] ?? 0).toDouble();
    final totalContacts = (_data['totalContacts'] ?? 0).toDouble();
    final activeUsers = (_data['activeUsers'] ?? 0).toDouble();
    final inactiveUsers = (_data['inactiveUsers'] ?? 0).toDouble();
    final newUsers = (_data['newUsers'] ?? 0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.analytics, color: theme.colorScheme.primary, size: 32),
              const SizedBox(width: 12),
              Text('Analytics', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _loadAnalytics),
            ],
          ),
          const SizedBox(height: 24),

          // Stat cards row
          Row(
            children: [
              _StatChip(icon: Icons.people, label: 'Total Users', value: totalUsers.toInt().toString(), color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.message, label: 'Total Messages', value: totalMessages.toInt().toString(), color: Colors.deepPurple),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.contacts, label: 'Total Contacts', value: totalContacts.toInt().toString(), color: Colors.teal),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.person_add, label: 'New Users', value: newUsers.toInt().toString(), color: Colors.green),
            ],
          ),
          const SizedBox(height: 32),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User status pie chart
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: activeUsers > 0 ? activeUsers : 1,
                                  title: '${activeUsers.toInt()}',
                                  color: Colors.green,
                                  radius: 60,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                PieChartSectionData(
                                  value: inactiveUsers > 0 ? inactiveUsers : 0.5,
                                  title: '${inactiveUsers.toInt()}',
                                  color: Colors.red,
                                  radius: 55,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendDot(color: Colors.green, label: 'Active'),
                            const SizedBox(width: 20),
                            _LegendDot(color: Colors.red, label: 'Inactive'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Platform bar chart
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Volume Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalUsers, color: theme.colorScheme.primary, width: 28, borderRadius: BorderRadius.circular(6))]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalMessages, color: Colors.deepPurple, width: 28, borderRadius: BorderRadius.circular(6))]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: totalContacts, color: Colors.teal, width: 28, borderRadius: BorderRadius.circular(6))]),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0: return const Text('Users', style: TextStyle(fontSize: 12));
                                        case 1: return const Text('Messages', style: TextStyle(fontSize: 12));
                                        case 2: return const Text('Contacts', style: TextStyle(fontSize: 12));
                                        default: return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: true, drawVerticalLine: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Growth chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Engagement Metrics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('(Simulated trend — real time-series data pending)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            // TODO: Replace with real daily active user counts from backend
                            spots: [
                              FlSpot(0, totalUsers * 0.1),
                              FlSpot(1, totalUsers * 0.25),
                              FlSpot(2, totalUsers * 0.35),
                              FlSpot(3, totalUsers * 0.5),
                              FlSpot(4, totalUsers * 0.7),
                              FlSpot(5, totalUsers * 0.85),
                              FlSpot(6, totalUsers),
                            ],
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withOpacity(0.15),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              FlSpot(0, totalMessages * 0.05),
                              FlSpot(1, totalMessages * 0.15),
                              FlSpot(2, totalMessages * 0.3),
                              FlSpot(3, totalMessages * 0.45),
                              FlSpot(4, totalMessages * 0.6),
                              FlSpot(5, totalMessages * 0.8),
                              FlSpot(6, totalMessages),
                            ],
                            isCurved: true,
                            color: Colors.deepPurple,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.deepPurple.withOpacity(0.1),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Today'];
                                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(labels[value.toInt()], style: const TextStyle(fontSize: 11)),
                                  );
                                }
                                return const Text('');
                              },
                              interval: 1,
                            ),
                          ),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                        gridData: const FlGridData(show: true),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _LegendDot(color: theme.colorScheme.primary, label: 'Users'),
                      const SizedBox(width: 20),
                      _LegendDot(color: Colors.deepPurple, label: 'Messages'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
