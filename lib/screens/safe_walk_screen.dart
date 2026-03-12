import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';
import '../services/emergency_service.dart';

/// Safe Walk mode – user sets a destination + timer.
/// If the user does not reach the destination before the timer expires,
/// the SOS is triggered automatically.
class SafeWalkScreen extends StatefulWidget {
  final String userId;

  const SafeWalkScreen({super.key, required this.userId});

  @override
  State<SafeWalkScreen> createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends State<SafeWalkScreen> {
  // Dependencies
  final LocationService _locationService = LocationService();
  late final EmergencyService _emergencyService;

  // Map
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _locationSub;

  // Timer state
  int _timerMinutes = 15;
  int _secondsRemaining = 0;
  Timer? _countdown;
  bool _isWalkActive = false;
  bool _isLoading = true;

  // Emergency state
  String? _emergencyId;

  @override
  void initState() {
    super.initState();
    _emergencyService = EmergencyService(locationService: _locationService);
    _initLocation();
  }

  // ---------------------------------------------------------------------------
  // Location initialisation
  // ---------------------------------------------------------------------------

  Future<void> _initLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentLatLng = latLng;
        _markers = _buildMarkers();
      });
    } catch (_) {}

    await _locationService.startTracking();
    _locationSub = _locationService.locationStream.listen(_onPositionUpdate);
    if (mounted) setState(() => _isLoading = false);
  }

  void _onPositionUpdate(Position pos) {
    final latLng = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _currentLatLng = latLng;
      _markers = _buildMarkers();
    });

    _mapController.future.then((c) {
      c.animateCamera(CameraUpdate.newLatLng(latLng));
    });

    // Auto-resolve: check if user is within 50 m of destination.
    if (_isWalkActive && _destinationLatLng != null) {
      final dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        _destinationLatLng!.latitude,
        _destinationLatLng!.longitude,
      );
      if (dist <= 50) _onSafeArrival();
    }
  }

  // ---------------------------------------------------------------------------
  // Walk controls
  // ---------------------------------------------------------------------------

  void _startWalk() {
    if (_destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please long-press the map to set your destination.')),
      );
      return;
    }

    setState(() {
      _isWalkActive = true;
      _secondsRemaining = _timerMinutes * 60;
    });

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);

      if (_secondsRemaining <= 0) {
        _countdown?.cancel();
        _triggerAutoSOS();
      }
    });
  }

  void _cancelWalk() {
    _countdown?.cancel();
    setState(() {
      _isWalkActive = false;
      _secondsRemaining = 0;
    });

    if (_emergencyId != null) {
      _emergencyService.cancelEmergency();
      _emergencyId = null;
    }
  }

  Future<void> _triggerAutoSOS() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Timer expired! Triggering SOS…'),
        backgroundColor: Colors.red,
      ),
    );

    try {
      _emergencyId = await _emergencyService.triggerSOS(widget.userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS failed: $e')),
        );
      }
    }
  }

  void _onSafeArrival() {
    _countdown?.cancel();
    if (!mounted) return;

    setState(() => _isWalkActive = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Arrived Safely!'),
          ],
        ),
        content: const Text('You have reached your destination.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF880E4F)),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_currentLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _currentLatLng!,
        infoWindow: const InfoWindow(title: 'You'),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
    if (_destinationLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    return markers;
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsRemaining > 120) return Colors.greenAccent;
    if (_secondsRemaining > 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _locationSub?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A12),
      appBar: AppBar(
        title: const Text('Safe Walk'),
        backgroundColor: const Color(0xFF880E4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF880E4F)),
            )
          : Column(
              children: [
                // ── Map ─────────────────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    child: GoogleMap(
                      onMapCreated: (c) => _mapController.complete(c),
                      initialCameraPosition: CameraPosition(
                        target: _currentLatLng ??
                            const LatLng(20.5937, 78.9629),
                        zoom: 15,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: !_isWalkActive,
                      onLongPress: _isWalkActive
                          ? null
                          : (latLng) {
                              setState(() {
                                _destinationLatLng = latLng;
                                _markers = _buildMarkers();
                              });
                            },
                    ),
                  ),
                ),

                // ── Control panel ────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A0F1E),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Timer display
                        if (_isWalkActive) ...[
                          Text(
                            _formattedTime,
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: _timerColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SOS triggers when timer hits 0:00',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          _buildCancelButton(),
                        ] else ...[
                          // Hint text
                          const Text(
                            'Long-press the map to set destination',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          // Timer picker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Timer:',
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(width: 12),
                              _buildTimerChip(5),
                              _buildTimerChip(10),
                              _buildTimerChip(15),
                              _buildTimerChip(30),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildStartButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget helpers
  // ---------------------------------------------------------------------------

  Widget _buildTimerChip(int minutes) {
    final selected = _timerMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _timerMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF880E4F) : const Color(0xFF3A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.pinkAccent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startWalk,
        icon: const Icon(Icons.directions_walk, size: 22),
        label: const Text('Start Safe Walk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF880E4F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFF880E4F).withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _cancelWalk,
        icon: const Icon(Icons.stop_circle_outlined, size: 22),
        label: const Text('Cancel Walk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
