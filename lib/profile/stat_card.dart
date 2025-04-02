import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color textColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                )),
            Text(value,
                style: TextStyle(
                  color: textColor,
                )),
          ],
        ),
      ),
    );
  }
}