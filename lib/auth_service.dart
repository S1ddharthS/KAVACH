import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_model.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Send OTP
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("KAVACH Auth Error: ${e.message}");
        onError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Verify OTP and Sign In
  Future<UserCredential?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await createUserProfile(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint("OTP Error: $e");
      return null;
    }
  }

  // Lead Responsibility: Store User in Firestore
  Future<void> createUserProfile(User user) async {
    DocumentSnapshot doc = await db.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? "",
      );
      await db.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }
}