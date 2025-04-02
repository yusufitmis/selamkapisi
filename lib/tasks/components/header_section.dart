import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final double totalProgress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color cardColor;
  final VoidCallback onFaithMessagePressed;

  const HeaderSection({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.totalProgress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.cardColor,
    required this.onFaithMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor.withOpacity(0.2), primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Görev Durumu',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$completedTasks/$totalTasks Tamamlandı',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Chip(
                backgroundColor: secondaryColor,
                label: Text(
                  '${(totalProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: totalProgress,
            backgroundColor: cardColor,
            color: secondaryColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.auto_awesome, color: secondaryColor),
            label: Text(
              'İman Tazeleme Mesajı Al',
              style: TextStyle(color: textColor),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              side: BorderSide(color: secondaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onFaithMessagePressed,
          ),
        ],
      ),
    );
  }
}