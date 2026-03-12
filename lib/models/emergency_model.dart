import 'package:cloud_firestore/cloud_firestore.dart';

/// Status values for an emergency record.
enum EmergencyStatus { active, resolved, cancelled }

/// Model representing a single emergency event stored in Firestore.
///
/// Firestore path: /emergencies/{emergencyId}
class EmergencyModel {
  final String emergencyId;
  final String userId;
  EmergencyStatus status;
  GeoPoint? location;
  String? audioUrl;
  final DateTime createdAt;

  EmergencyModel({
    required this.emergencyId,
    required this.userId,
    this.status = EmergencyStatus.active,
    this.location,
    this.audioUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory EmergencyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyModel(
      emergencyId: doc.id,
      userId: data['userId'] as String,
      status: _statusFromString(data['status'] as String? ?? 'active'),
      location: data['location'] as GeoPoint?,
      audioUrl: data['audioUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'status': status.name,
        'location': location,
        'audioUrl': audioUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static EmergencyStatus _statusFromString(String value) {
    switch (value) {
      case 'resolved':
        return EmergencyStatus.resolved;
      case 'cancelled':
        return EmergencyStatus.cancelled;
      default:
        return EmergencyStatus.active;
    }
  }

  EmergencyModel copyWith({
    EmergencyStatus? status,
    GeoPoint? location,
    String? audioUrl,
  }) =>
      EmergencyModel(
        emergencyId: emergencyId,
        userId: userId,
        status: status ?? this.status,
        location: location ?? this.location,
        audioUrl: audioUrl ?? this.audioUrl,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'EmergencyModel(id: $emergencyId, userId: $userId, status: ${status.name})';
}
