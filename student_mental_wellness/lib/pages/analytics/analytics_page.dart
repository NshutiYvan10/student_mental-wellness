import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveService.moodsBox);
    final entries = box.values.toList().cast<Map>();
    entries.sort((a, b) => (DateTime.parse(a['date'] as String))
        .compareTo(DateTime.parse(b['date'] as String)));
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      final mood = (entries[i]['mood'] as int).toDouble();
      spots.add(FlSpot(i.toDouble(), mood));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Trend', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                      gradient: const LinearGradient(colors: [Color(0xFFa1c4fd), Color(0xFFc2e9fb)]),
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFa1c4fd).withValues(alpha: 0.3),
                            const Color(0xFFc2e9fb).withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(_insight(entries)),
          ],
        ),
      ),
    );
  }

  String _insight(List<Map> entries) {
    if (entries.length < 3) return 'Log more moods to unlock insights.';
    final last = (entries.last['mood'] as int).toDouble();
    final prev = (entries[entries.length - 2]['mood'] as int).toDouble();
    if (last > prev) return 'Nice! Your recent mood trend is improving.';
    if (last < prev) return 'Consider a short meditation to lift your mood.';
    return 'Your mood is steady. Keep journaling for clarity.';
  }
}


