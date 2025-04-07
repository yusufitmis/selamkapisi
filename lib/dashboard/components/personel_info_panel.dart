import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PersonalInfoPanel extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PersonalInfoPanel({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEE').format(DateTime.now()).toLowerCase().substring(0, 3); // "mon", "tue" etc.

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return _buildErrorContainer();
        }

        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer();
        }

        final halalLifeScore = userSnapshot.data?['totalScore']?.toDouble() ?? 0.0;

        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('prayerRecords')
              .doc(_auth.currentUser?.uid)
              .collection('weekly')
              .doc('current')
              .snapshots(),
          builder: (context, prayerSnapshot) {
            if (prayerSnapshot.hasError) {
              return _buildErrorContainer();
            }

            if (prayerSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingContainer();
            }

            final data = prayerSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final todayData = data[today] as Map<String, dynamic>? ?? {};

            return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                BoxShadow(
                color: Colors.black.withAlpha(128),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
                )],
            border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
            'KİŞİSEL DURUMUM',
            style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.amber[300],
            letterSpacing: 1.2,
            ),
            ),
            const SizedBox(height: 16),
            Row(
            children: [
            SizedBox(
            width: 100,
            height: 100,
            child: Stack(
            alignment: Alignment.center,
            children: [
            CircularProgressIndicator(
            value: halalLifeScore / 100,
            strokeWidth: 10,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
            _getScoreColor(halalLifeScore),
            ),
            ),
            Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Text(
            halalLifeScore.toStringAsFixed(1),
            style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.amber[300],
            ),
            ),
            Text(
            'Puan',
            style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            ),
            ),
            ],
            ),
            ],
            ),
            ),
            const SizedBox(width: 16),
            Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
            'Bugünkü İbadetlerim',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.amber[200],
            ),
            ),
            const SizedBox(height: 8),
            _buildPrayerStatus('Sabah', todayData['fajr'] ?? false),
            _buildPrayerStatus('Öğle', todayData['dhuhr'] ?? false),
            _buildPrayerStatus('İkindi', todayData['asr'] ?? false),
            _buildPrayerStatus('Akşam', todayData['maghrib'] ?? false),
            _buildPrayerStatus('Yatsı', todayData['isha'] ?? false),
            ],
            ),
            ),
            ],
            ),
            ],
            ),
            );
            },
        );
      },
    );
  }

  Widget _buildPrayerStatus(String prayerName, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.circle,
          color: isCompleted ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          prayerName,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: const Center(
        child: Text(
          'Veri yüklenirken hata oluştu',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.amber[300],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}