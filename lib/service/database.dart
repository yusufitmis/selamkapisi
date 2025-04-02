import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future addUser(String userId, Map<String, dynamic>  userInfoMap){
    return FirebaseFirestore.instance.collection("User").doc(userId).set(userInfoMap);
  }

  Future<void> addFatwaQuestion(String question) async {
    await _firestore.collection('fatwaRequests').add({
      'question': question,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // Vaizle sohbet başlat
  Future<void> startChatWithPreacher(String preacherId, String message) async {
    await _firestore
        .collection('preachers')
        .doc(preacherId)
        .collection('chats')
        .add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Onaylı fetvaları getir
  Stream<QuerySnapshot> getApprovedFatwas() {
    return _firestore
        .collection('fatwas')
        .where('status', isEqualTo: 'approved')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Canlı vaizleri getir
  Stream<QuerySnapshot> getLivePreachers() {
    return _firestore
        .collection('preachers')
        .where('isLive', isEqualTo: true)
        .snapshots();
  }
}