import 'package:flutter/material.dart';

class FaithMessageDialog extends StatelessWidget {
  final Color cardColor;
  final Color secondaryColor;
  final Color textColor;
  final Color primaryColor;
  final VoidCallback onSharePressed;

  const FaithMessageDialog({
    super.key,
    required this.cardColor,
    required this.secondaryColor,
    required this.textColor,
    required this.primaryColor,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final messages = [
      "Allah'ın rahmeti üzerine olsun! Bugün bir ayet paylaşarak sevap kazanmaya ne dersin?",
      "Peygamberimizin bir hadisini paylaşarak sünneti yaşatabilirsin.",
      "Milli değerlerimizi paylaşarak gençlere örnek olabilirsin.",
    ];

    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 40, color: secondaryColor),
            const SizedBox(height: 16),
            Text(
              'İman Tazeleme Mesajı',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              messages[DateTime.now().second % messages.length],
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor.withOpacity(0.9)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'KAPAT',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onSharePressed();
                    },
                    child: Text(
                      'PAYLAŞ',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}