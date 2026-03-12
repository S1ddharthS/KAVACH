import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Required for debugPrint
import 'user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to Send OTP
  Future<void> verifyPhoneNumber(
    String phoneNumber, 
    Function(String) onCodeSent, 
    Function(String) onError,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
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
    } catch (e) {
      onError(e.toString());
    }
  }

  // Function to Verify OTP and Sign In
  Future<UserCredential?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _saveUserToDatabase(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint("KAVACH OTP Error: ${e.toString()}");
      return null;
    }
  }

  // Save the Lead-defined 'users' collection data
  Future<void> _saveUserToDatabase(User user) async {
    UserModel newUser = UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? "",
      guardianContacts: [], // Initialized as empty list
    );

    await _db.collection('users').doc(user.uid).set(
      newUser.toMap(), 
      SetOptions(merge: true),
    );
  }
}