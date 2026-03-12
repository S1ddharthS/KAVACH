class UserModel {
  final String uid;
  final String phoneNumber;
  final List<String> guardianContacts;

  UserModel({
    required this.uid, 
    required this.phoneNumber, 
    this.guardianContacts = const [],
  });

  // Convert to Map for Firestore (users collection)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'guardianContacts': guardianContacts,
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      guardianContacts: List<String>.from(map['guardianContacts'] ?? []),
    );
  }
}