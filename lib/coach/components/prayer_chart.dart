import 'package:flutter/material.dart';
import 'package:selamkapisi/coach/components/parayer_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PrayerChart extends StatelessWidget {
  final List<PrayerData> prayerData;

  const PrayerChart({
    super.key,
    required this.prayerData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<PrayerData, String>(
                    dataSource: prayerData,
                    xValueMapper: (PrayerData data, _) => data.day,
                    yValueMapper: (PrayerData data, _) => data.completedPrayers,
                    color: Colors.amber[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildPrayerLegends(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerLegends() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegend(Icons.wb_sunny, 'Sabah', Colors.green),
        _buildLegend(Icons.sunny, 'Öğle', Colors.blue),
        _buildLegend(Icons.brightness_4, 'İkindi', Colors.orange),
        _buildLegend(Icons.nights_stay, 'Akşam', Colors.purple),
        _buildLegend(Icons.dark_mode, 'Yatsı', Colors.deepPurple),
      ],
    );
  }

  Widget _buildLegend(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}