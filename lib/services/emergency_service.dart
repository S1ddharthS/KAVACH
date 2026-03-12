import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/emergency_model.dart';
import 'location_service.dart';

/// Manages creating, updating, and resolving emergency records in Firestore.
///
/// Responsibilities:
///   - Create a new emergency document when SOS is triggered.
///   - Push live GPS updates every [locationUpdateInterval] seconds.
///   - Mark the emergency as resolved or cancelled.
class EmergencyService {
  EmergencyService({
    FirebaseFirestore? firestore,
    LocationService? locationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _locationService = locationService ?? LocationService();

  final FirebaseFirestore _firestore;
  final LocationService _locationService;

  static const Duration locationUpdateInterval = Duration(seconds: 5);

  String? _activeEmergencyId;
  Timer? _locationUpdateTimer;

  // ---------------------------------------------------------------------------
  // SOS Trigger
  // ---------------------------------------------------------------------------

  /// Triggers an SOS alert for [userId].
  ///
  /// Creates a Firestore record and starts pushing location updates
  /// every [locationUpdateInterval].
  /// Returns the newly created [emergencyId].
  Future<String> triggerSOS(String userId) async {
    // Fetch initial location.
    Position position;
    try {
      position = await _locationService.getCurrentPosition();
    } catch (_) {
      // If location fails, still create the record with null location.
      position = Position(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    final geoPoint = GeoPoint(position.latitude, position.longitude);

    final emergency = EmergencyModel(
      emergencyId: '', // Firestore will assign.
      userId: userId,
      location: geoPoint,
      status: EmergencyStatus.active,
    );

    final docRef = await _firestore
        .collection('emergencies')
        .add(emergency.toMap());

    _activeEmergencyId = docRef.id;

    // Start periodic location push.
    await _locationService.startTracking();
    _startLocationUpdates(_activeEmergencyId!);

    return _activeEmergencyId!;
  }

  // ---------------------------------------------------------------------------
  // Periodic location updates
  // ---------------------------------------------------------------------------

  void _startLocationUpdates(String emergencyId) {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(locationUpdateInterval, (_) async {
      final pos = _locationService.currentPosition;
      if (pos == null) return;

      await _updateLocation(emergencyId, pos.latitude, pos.longitude);
    });
  }

  Future<void> _updateLocation(
      String emergencyId, double lat, double lng) async {
    await _firestore
        .collection('emergencies')
        .doc(emergencyId)
        .update({'location': GeoPoint(lat, lng)});
  }

  // ---------------------------------------------------------------------------
  // Resolution helpers
  // ---------------------------------------------------------------------------

  /// Marks the active emergency as resolved and stops tracking.
  Future<void> resolveEmergency() async {
    await _setStatus(EmergencyStatus.resolved);
  }

  /// Marks the active emergency as cancelled and stops tracking.
  Future<void> cancelEmergency() async {
    await _setStatus(EmergencyStatus.cancelled);
  }

  Future<void> _setStatus(EmergencyStatus status) async {
    if (_activeEmergencyId == null) return;

    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    await _locationService.stopTracking();

    await _firestore
        .collection('emergencies')
        .doc(_activeEmergencyId)
        .update({'status': status.name});

    _activeEmergencyId = null;
  }

  // ---------------------------------------------------------------------------
  // Audio URL setter
  // ---------------------------------------------------------------------------

  /// Attaches a recorded audio URL to the emergency record (called by Sharon's
  /// AudioService after upload).
  Future<void> attachAudioUrl(String emergencyId, String url) async {
    await _firestore
        .collection('emergencies')
        .doc(emergencyId)
        .update({'audioUrl': url});
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Returns all active emergencies for [userId].
  Future<List<EmergencyModel>> getActiveEmergencies(String userId) async {
    final snapshot = await _firestore
        .collection('emergencies')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(EmergencyModel.fromFirestore).toList();
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    _locationUpdateTimer?.cancel();
    await _locationService.dispose();
  }
}
