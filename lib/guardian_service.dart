import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GuardianService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> addGuardian(String name, String phone) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await db.collection('users').doc(uid).update({
        'guardianContacts': FieldValue.arrayUnion([
          {'name': name, 'phone': phone}
        ])
      });
      debugPrint("KAVACH: Guardian added.");
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Stream<DocumentSnapshot> getGuardianStream() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    return db.collection('users').doc(uid).snapshots();
  }
}