import 'package:flutter/material.dart';

class FatwaResponseDialog extends StatelessWidget {
  final Map<String, dynamic> fatwa;

  const FatwaResponseDialog({
    super.key,
    required this.fatwa,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(fatwa['question'] ?? 'Soru yok'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fatwa['status'] == 'under_review')
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Bu cevap denetim için işaretlenmiştir',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            Text(
              fatwa['answer'] ?? 'Cevap bulunamadı',
              textAlign: TextAlign.justify,
            ),
            if (fatwa['references'] != null && (fatwa['references'] as List).isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Referanslar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ...(fatwa['references'] as List).map((ref) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $ref'),
              )).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}