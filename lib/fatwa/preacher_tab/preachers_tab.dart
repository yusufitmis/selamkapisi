import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'preacher_detail.dart';
import 'preacher_model.dart';

class PreachersTab extends StatefulWidget {
  const PreachersTab({super.key});

  @override
  State<PreachersTab> createState() => _PreachersTabState();
}

class _PreachersTabState extends State<PreachersTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Preacher? _selectedPreacher;

  Stream<QuerySnapshot> _getPreachers() {
    return _firestore.collection('preachers').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPreachers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final preachers = snapshot.data!.docs.map((doc) {
          return Preacher.fromFirestore(doc);
        }).toList();

        return _selectedPreacher == null
            ? PreachersListView(
          preachers: preachers,
          onPreacherSelected: (preacher) => setState(() => _selectedPreacher = preacher),
        )
            : PreacherDetailView(
          preacher: _selectedPreacher!,
          onBackPressed: () => setState(() => _selectedPreacher = null),
        );
      },
    );
  }
}

class PreachersListView extends StatelessWidget {
  final List<Preacher> preachers;
  final ValueChanged<Preacher> onPreacherSelected;

  const PreachersListView({
    super.key,
    required this.preachers,
    required this.onPreacherSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'Tarihi Din Alimleri'),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: preachers.length,
            itemBuilder: (context, index) {
              return PreacherCard(
                preacher: preachers[index],
                onPressed: () => onPreacherSelected(preachers[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.amber[300],
        ),
      ),
    );
  }
}

class PreacherCard extends StatelessWidget {
  final Preacher preacher;
  final VoidCallback onPressed;

  const PreacherCard({
    super.key,
    required this.preacher,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  preacher.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preacher.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _ScheduleInfo(schedule: preacher.schedule),
                  const SizedBox(height: 8),
                  _ActionButtons(
                    onListenPressed: () {},
                    onAskPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleInfo extends StatelessWidget {
  final String schedule;

  const _ScheduleInfo({
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          schedule,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onListenPressed;
  final VoidCallback onAskPressed;

  const _ActionButtons({
    required this.onListenPressed,
    required this.onAskPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.headphones, size: 16),
            label: const Text('Dinle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: onListenPressed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat, size: 16),
            label: const Text('Soru Sor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onPressed: onAskPressed,
          ),
        ),
      ],
    );
  }
}