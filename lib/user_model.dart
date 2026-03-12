class UserModel {
  final String uid;
  final String phoneNumber;
  final List<dynamic> guardianContacts;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.guardianContacts = const [],
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'guardianContacts': guardianContacts,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      guardianContacts: List<dynamic>.from(map['guardianContacts'] ?? []),
    );
  }
}