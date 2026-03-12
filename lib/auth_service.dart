import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // STEP 1: Send OTP to User's Phone
  Future<void> verifyPhoneNumber(
      String phoneNumber, 
      Function(String) onCodeSent, 
      Function(String) onError) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (mostly on Android)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Verification Failed");
          debugPrint("KAVACH Auth Error: ${e.message}");
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

  // STEP 2: Verify OTP and Sign In
  Future<UserCredential?> signInWithOTP(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // STEP 3: Store User in Firestore 'users' collection
      if (userCredential.user != null) {
        await _saveUserToDatabase(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      debugPrint("KAVACH OTP Error: ${e.toString()}");
      return null;
    }
  }

  // Create User Profile in Firestore
  Future<void> _saveUserToDatabase(User user) async {
    UserModel newUser = UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? "",
      guardianContacts: [], // Initialize empty as per Lead requirements
    );

    await _db.collection('users').doc(user.uid).set(newUser.toMap(), SetOptions(merge: true));
    debugPrint("KAVACH: User profile saved to Firestore");
  }
}