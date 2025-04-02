import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  final double score;
  final double averageScore;
  final VoidCallback onComparePressed;

  const ScoreCard({
    super.key,
    required this.score,
    required this.averageScore,
    required this.onComparePressed,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreText(),
                _buildProgressCircle(),
              ],
            ),
            const SizedBox(height: 10),
            _buildLinearProgress(),
            const SizedBox(height: 8),
            _buildComparisonRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HELAL YAŞAM PUANI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amber[300],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getScoreColor(score),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score - averageScore).toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: score > averageScore ? Colors.green : Colors.red,
                ),
              ),
              Text(
                'Ortalamadan',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinearProgress() {
    return LinearProgressIndicator(
      value: score / 100,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        _getScoreColor(score),
      ),
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildComparisonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Çevrenizdeki ortalama: ${averageScore.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: onComparePressed,
          child: const Text(
            'Detaylı Karşılaştırma',
            style: TextStyle(color: Colors.amber),
          ),
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