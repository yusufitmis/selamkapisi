import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final int prayerCount;
  final int quranPages;
  final double charityAmount;
  final int socialPoints;
  final int totalScore;
  double profilePuan;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.prayerCount = 0,
    this.quranPages = 0,
    this.charityAmount = 0,
    this.socialPoints = 0,
    this.totalScore = 0,
    this.profilePuan = 0.0
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      prayerCount: data['prayerCount'] ?? 0,
      quranPages: data['quranPages'] ?? 0,
      charityAmount: data['charityAmount']?.toDouble() ?? 0,
      socialPoints: data['socialPoints'] ?? 0,
      totalScore: data['totalScore'] ?? 0,
      profilePuan: (data['profilePuan'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'prayerCount': prayerCount,
      'quranPages': quranPages,
      'charityAmount': charityAmount,
      'socialPoints': socialPoints,
      'totalScore': totalScore,
      'profilePuan': profilePuan
    };
  }
}