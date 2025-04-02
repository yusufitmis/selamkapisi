import 'package:cloud_firestore/cloud_firestore.dart';

class Preacher {
  final String id;
  final String name;
  final String image;
  final bool isLive;
  final String schedule;
  final String aiModelId;
  final List<Sermon> sermons;

  Preacher({
    required this.id,
    required this.name,
    required this.image,
    required this.isLive,
    required this.schedule,
    required this.aiModelId,
    required this.sermons,
  });

  factory Preacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Preacher(
      id: doc.id,
      name: data['name'],
      image: data['image'],
      isLive: data['isLive'],
      schedule: data['schedule'],
      aiModelId: data['aiModelId'],
      sermons: (data['sermons'] as List).map((e) => Sermon.fromMap(e)).toList(),
    );
  }
}

class Sermon {
  final String title;
  final String duration;
  final String audioUrl;

  Sermon({
    required this.title,
    required this.duration,
    required this.audioUrl,
  });

  factory Sermon.fromMap(Map<String, dynamic> map) {
    return Sermon(
      title: map['title'],
      duration: map['duration'],
      audioUrl: map['audioUrl'],
    );
  }
}