import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service that handles GPS permission checks and continuous location updates.
///
/// Call [startTracking] to begin a stream of [Position] updates.
/// Call [stopTracking] to cancel the subscription.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;

  /// Current position (updated as location changes).
  Position? currentPosition;

  /// Stream controller that external listeners can attach to.
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationController.stream;

  // ---------------------------------------------------------------------------
  // Permission helpers
  // ---------------------------------------------------------------------------

  /// Requests location permissions and returns [true] if granted.
  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  // ---------------------------------------------------------------------------
  // Tracking
  // ---------------------------------------------------------------------------

  /// Starts position tracking at the given [distanceFilter] (metres).
  ///
  /// Location updates are emitted to [locationStream] and also
  /// cached in [currentPosition].
  Future<void> startTracking({int distanceFilter = 10}) async {
    final granted = await requestPermissions();
    if (!granted) {
      throw Exception('Location permission denied. Cannot start tracking.');
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        currentPosition = position;
        if (!_locationController.isClosed) {
          _locationController.add(position);
        }
      },
      onError: (Object error) {
        // Propagate errors through the stream so callers can react.
        if (!_locationController.isClosed) {
          _locationController.addError(error);
        }
      },
    );
  }

  /// Stops tracking and releases resources.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // ---------------------------------------------------------------------------
  // One-shot fetch
  // ---------------------------------------------------------------------------

  /// Returns the device's current [Position] without starting continuous
  /// tracking.
  Future<Position> getCurrentPosition() async {
    final granted = await requestPermissions();
    if (!granted) {
      throw Exception('Location permission denied.');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ---------------------------------------------------------------------------
  // Disposal
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    await stopTracking();
    await _locationController.close();
  }
}
