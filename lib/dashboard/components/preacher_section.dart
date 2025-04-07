import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selamkapisi/fatwa/preacher_tab/preacher_list.dart';

class PreachersSection extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PreachersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('preachers').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorContainer();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingContainer();
        }

        final preachers = snapshot.data?.docs ?? [];

        return _buildMainContainer(context, preachers);
      },
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
        )],
    border: Border.all(color: Colors.grey[700]!),
    ),
    child: Text(
    'Vaizler yüklenirken hata oluştu',
    style: TextStyle(
    color: Colors.red,
    fontSize: 14,
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
        )],
    border: Border.all(color: Colors.grey[700]!),
    ),
    child: Center(
    child: CircularProgressIndicator(
    color: Colors.amber[300],
    ),
    ),
    );
  }

  Widget _buildMainContainer(BuildContext context, List<DocumentSnapshot> preachers) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DİJİTAL VAAZLAR',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[300],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: preachers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: preachers.length,
              itemBuilder: (context, index) {
                final preacher = preachers[index];
                return _buildPreacherItem(context, preacher);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Henüz dijital vaiz eklenmemiş',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPreacherItem(BuildContext context, DocumentSnapshot preacher) {
    return GestureDetector(
      onTap: () => _showPreachersList(context),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amber,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: preacher['imageUrl'],
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    placeholder: (context, url) => CircularProgressIndicator(
                      color: Colors.amber[300],
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.amber[300],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Center(
                child: Text(
                  preacher['name'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreachersList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: PreachersList(),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.5).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

  }
}