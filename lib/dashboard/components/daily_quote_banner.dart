import 'package:flutter/material.dart';

class DailyQuoteBanner extends StatelessWidget {
  final VoidCallback onAskQuestion;
  final VoidCallback onShowSchedule;

  const DailyQuoteBanner({
    super.key,
    required this.onAskQuestion,
    required this.onShowSchedule,
  });

  @override
  Widget build(BuildContext context) {
    const dailyQuote = "Sabır, imanın yarısıdır.";
    const fakePreacher = {
      'name': 'İmam Gazali',
      'image': 'assets/gazali.jpg'
    };

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF1a1a1a)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'GÜNÜN VAAZI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[300],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: AssetImage(fakePreacher['image']!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fakePreacher['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[200],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dailyQuote,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildControlButton(Icons.play_circle_fill, "Dinle", () {}),
              _buildControlButton(Icons.mic, "Soru Sor", onAskQuestion),
              _buildControlButton(Icons.calendar_today, "Takvim", onShowSchedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32),
          color: Colors.amber,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}