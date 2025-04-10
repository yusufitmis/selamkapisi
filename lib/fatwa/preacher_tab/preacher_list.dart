import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../google_ads.dart';
import 'preacher_details.dart';
import 'question_dialog.dart';

class PreachersList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAds? googleAds;

  // Color scheme
  final Color _primaryColor = const Color(0xFF121212);
  final Color _secondaryColor = const Color(0xFFD4AF37);
  final Color _accentColor = const Color(0xFF64B5F6);
  final Color _backgroundColor = Colors.white;
  final Color _textColor = const Color(0xFF333333);

  PreachersList({super.key, required this.googleAds});

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('preachers')
          .where('isHistorical', isEqualTo: true)
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Liste yüklenirken hata oluştu',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
              strokeWidth: 3,
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Henüz vaiz eklenmemiş',
              style: TextStyle(
                color: _textColor,
                fontSize: 18,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var preacher = snapshot.data!.docs[index];
            return _buildPreacherCard(context, preacher, currentUserId);
          },
        );
      },
    );
  }

  Widget _buildPreacherCard(BuildContext context, DocumentSnapshot preacher, String currentUserId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.1).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showPreacherDetailsWithAd(context, preacher, currentUserId),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Preacher Image
                Hero(
                  tag: 'preacher-${preacher.id}',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _secondaryColor.withAlpha((255 * 0.3).round()),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: preacher['imageUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(_secondaryColor),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: _accentColor.withAlpha((255 * 0.1).round()),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: _secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Preacher Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preacher['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preacher['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Question Button
                Container(
                  decoration: BoxDecoration(
                    color: _secondaryColor.withAlpha((255 * 0.2).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.question_answer,
                      color: _secondaryColor,
                      size: 32,
                    ),
                    onPressed: () => _showQuestionDialogWithAd(context, preacher),
                    tooltip: 'Soru Sor',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPreacherDetailsWithAd(BuildContext context,
      DocumentSnapshot preacher, String currentUserId) async {
    try {
      // Try to show ad first
      await googleAds?.interstitialAd?.show();
    } catch (e) {
      debugPrint('Error showing ad: $e');
    } finally {
      // Always show details after ad attempt
      if (context.mounted) {
        _showPreacherDetails(context, preacher, currentUserId);
      }
    }
  }

  void _showPreacherDetails(BuildContext context,
      DocumentSnapshot preacher, String currentUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PreacherDetails(
        preacher: preacher,
        currentUserId: currentUserId,
      ),
    );
  }

  Future<void> _showQuestionDialogWithAd(BuildContext context,
      DocumentSnapshot preacher) async {
    try {
      // Try to show ad first
      await googleAds?.interstitialAd?.show();
    } catch (e) {
      debugPrint('Error showing ad: $e');
    } finally {
      // Always show dialog after ad attempt
      if (context.mounted) {
        _showQuestionDialog(context, preacher);
      }
    }
  }

  void _showQuestionDialog(BuildContext context, DocumentSnapshot preacher) {
    showDialog(
      context: context,
      builder: (context) => QuestionDialog(preacher: preacher),
    );
  }
}