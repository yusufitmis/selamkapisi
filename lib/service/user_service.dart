import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> getUserData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış");

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> updateProfile(String displayName, String? photoUrl) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Firebase Auth'ta güncelleme
    await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);

    // Firestore'da güncelleme
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': displayName,
      'photoUrl': photoUrl,
    });
  }

  Stream<UserModel> getUserStream() {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı giriş yapmamış");

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (doc) => UserModel.fromFirestore(doc),
    );
  }

  Future<void> incrementUserStats({
    int? prayerCount,
    int? quranPages,
    double? charityAmount,
    int? socialPoints,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (prayerCount != null) updates['prayerCount'] = FieldValue.increment(prayerCount);
    if (quranPages != null) updates['quranPages'] = FieldValue.increment(quranPages);
    if (charityAmount != null) updates['charityAmount'] = FieldValue.increment(charityAmount);
    if (socialPoints != null) updates['socialPoints'] = FieldValue.increment(socialPoints);

    // Toplam puanı otomatik güncelle
    updates['totalScore'] = FieldValue.increment(
        (prayerCount ?? 0) * 10 +
            (quranPages ?? 0) * 2 +
            (charityAmount ?? 0) * 0.5 +
            (socialPoints ?? 0) * 0.1
    );

    await _firestore.collection('users').doc(user.uid).update(updates);
  }

  Future<void> incrementPrayerCount([int value = 1]) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .update({
      'prayerCount': FieldValue.increment(value),
      'totalScore': FieldValue.increment(value * 1)
    });
  }

  Future<void> incrementQuranPages([int value = 1]) async {
    await _updateStat('quranPages', value, 2);
  }

  Future<void> incrementCharity([double value = 1.0]) async {
    await _updateStat('charityAmount', value, 0.5);
  }

  Future<void> _updateStat(String field, num value, num multiplier) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .update({
      field: FieldValue.increment(value),
      'totalScore': FieldValue.increment(value * multiplier)
    });
  }

  Future<void> decrementPrayerCount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'prayerCount': FieldValue.increment(-1)
    });
  }

  Future<void> checkAndResetScore() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastReset = prefs.getString('lastScoreResetDate');
    final weekCount = prefs.getInt('weekCounter') ?? 0;

    // Hafta sayacını güncelle
    if (lastReset == null || _getLastMonday(now).isAfter(DateTime.parse(lastReset))) {
      await prefs.setInt('weekCounter', weekCount + 1);
      await prefs.setString('lastScoreResetDate', _getLastMonday(now).toString());

      // 6 hafta dolunca sıfırla
      if (weekCount >= 5) {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'prayerCount': 0,
            'quranPages': 0,
            'charityAmount': 0.0,
            'socialPoints': 0,
          });
          await prefs.setInt('weekCounter', 0);
        }
      }
    }
  }
  DateTime _getLastMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Add this to your UserService class
  Future<void> resetUserStats(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'prayerCount': 0,
      'quranPages': 0,
      'charityAmount': 0.0,
      'socialPoints': 0,
      'totalScore': 0,
      // profilePuan sıfırlanmıyor!
    });
  }

  Future<void> updateProfilePuan(double newPuan) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Kullanıcı giriş yapmamış");

      await _firestore.collection('users').doc(user.uid).update({
        'profilePuan': newPuan,
      });

      debugPrint('✅ profilePuan güncellendi: $newPuan');
    } catch (e) {
      debugPrint('❌ profilePuan güncelleme hatası: $e');
      rethrow;
    }
  }

}