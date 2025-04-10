import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selamkapisi/fatwa/preacher_tab/question_dialog.dart';
import 'package:selamkapisi/fatwa/preacher_tab/preacher_details.dart';

import '../../google_ads.dart';

class DailyQuoteBanner extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DailyQuoteBanner({super.key});
  @override

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('questions')
          .where('isAnswered', isEqualTo: true)
          .snapshots(),
      builder: (context, questionsSnapshot) {
        if (questionsSnapshot.hasError) {
          return _buildErrorContainer();
        }

        if (questionsSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer();
        }

        final questions = questionsSnapshot.data?.docs ?? [];

        if (questions.isEmpty) {
          return _buildEmptyState();
        }

        // Count questions per preacher
        final preacherQuestionCount = <String, int>{};
        for (final question in questions) {
          final preacherId = question['preacherId'] as String? ?? '';
          preacherQuestionCount[preacherId] = (preacherQuestionCount[preacherId] ?? 0) + 1;
        }

        if (preacherQuestionCount.isEmpty) {
          return _buildEmptyState();
        }

        // Get preacher with most questions
        final topPreacherId = preacherQuestionCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('preachers').doc(topPreacherId).snapshots(),
          builder: (context, preacherSnapshot) {
            if (preacherSnapshot.hasError || !preacherSnapshot.hasData) {
              return _buildErrorContainer();
            }

            final preacherData = preacherSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final preacherName = preacherData['name'] ?? 'Vaiz';
            final preacherImage = preacherData['imageUrl'] ?? '';
            final preacherQuote = preacherData['quote'] ?? '';

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
                    color: Colors.amber.withAlpha(50),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.amber.withAlpha(76)),
              ),
              child: Column(
                children: [
                  Text(
                    'EN ÇOK SORU SORULAN VAİZ',
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
                          child: preacherImage.isNotEmpty
                              ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: preacherImage,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                    color: Colors.amber[300],
                                  ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.amber[300],
                              ),
                            ),
                          )
                              : Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.amber[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preacherName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[200],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              preacherQuote.isNotEmpty
                                  ? preacherQuote
                                  : '$preacherName soru sormak için butona basın',
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Soru Sor Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => {_showQuestionDialog(context, preacherSnapshot.data!),},
                        child: const Text(
                          'SORU SOR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Sorduğum Sorular Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.amber),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () => _showPreacherDetails(context, preacherSnapshot.data!, currentUserId),
                        child: const Text(
                          'SORDUĞUM SORULAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
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

  void _showQuestionDialog(BuildContext context, DocumentSnapshot preacher) {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(preacher: preacher),
    );
  }

  void _showPreacherDetails(BuildContext context, DocumentSnapshot preacher, String currentUserId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(preacher['name']),
          ),
          body: PreacherDetails(
            preacher: preacher,
            currentUserId: currentUserId,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContainer() {
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
            color: Colors.amber.withAlpha(50),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.amber.withAlpha(76)),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Color(0xFF1a1a1a)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withAlpha(50),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.amber.withAlpha(76)),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.amber[300],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            color: Colors.amber.withAlpha(50),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.amber.withAlpha(76)),
      ),
      child: const Center(
        child: Text(
          'Henüz soru sorulan vaiz bulunamadı',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}