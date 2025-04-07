import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final double score;
  final double averageScore;
  final VoidCallback onComparePressed;
  final int weeksLeft;
  final int currentWeek;


  const ScoreCard({
    super.key,
    required this.score,
    required this.averageScore,
    required this.onComparePressed,
    required this.weeksLeft,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAboveAverage = score > averageScore;
    final double difference = (score - averageScore).abs();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            const Text(
              'DİNİ HAYAT PUANINIZ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8),

            // Ana Puan Gösterimi
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getScoreColor(score),
                    width: 8,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // İlerleme Çubukları
            _buildProgressItem(
                'Hafta İlerleme',
                ((currentWeek - 1) / 6).clamp(0.0, 1.0), // currentWeek 1-6 arası olduğu için
                '$currentWeek/6 hafta'
            ),
            const SizedBox(height: 12),
            _buildProgressItem('Puan İlerleme', score/100, '${score.toStringAsFixed(0)}/100 puan'),
            const SizedBox(height: 16),

            // Karşılaştırma Bilgisi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAboveAverage ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isAboveAverage ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isAboveAverage ? Colors.green : Colors.red,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Çevrenizdekilerden ${difference.toStringAsFixed(0)} puan ${isAboveAverage ? 'yüksek' : 'düşük'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Buton

          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getScoreColor(value * 100),
                ),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}