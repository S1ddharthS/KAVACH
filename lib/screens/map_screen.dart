import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/location_service.dart';
import '../services/emergency_service.dart';

/// Full-screen map showing the user's live position and active emergency
/// location updates.
///
/// Pass [userId] and an active [emergencyId] to start tracking in SOS mode;
/// omit [emergencyId] for a simple live-location view.
class MapScreen extends StatefulWidget {
  final String userId;
  final String? emergencyId;

  const MapScreen({super.key, required this.userId, this.emergencyId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Services
  final LocationService _locationService = LocationService();
  late EmergencyService _emergencyService;

  // Map controller
  final Completer<GoogleMapController> _mapController = Completer();

  // State
  LatLng? _currentLatLng;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _locationSub;
  bool _isLoading = true;

  static const _initialZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _emergencyService = EmergencyService(locationService: _locationService);
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      _updatePosition(pos.latitude, pos.longitude);
    } catch (e) {
      // Show snackbar if permissions denied.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }

    // Start continuous tracking.
    await _locationService.startTracking();
    _locationSub = _locationService.locationStream.listen((pos) {
      _updatePosition(pos.latitude, pos.longitude);
    });

    if (mounted) setState(() => _isLoading = false);
  }

  void _updatePosition(double lat, double lng) {
    final latLng = LatLng(lat, lng);
    setState(() {
      _currentLatLng = latLng;
      _markers = {
        Marker(
          markerId: const MarkerId('user'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed),
        ),
      };
    });

    // Animate camera to follow user.
    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -----------------------------------------------------------------------
      // App Bar
      // -----------------------------------------------------------------------
      appBar: AppBar(
        title: const Text('Live Location'),
        backgroundColor: const Color(0xFF880E4F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.emergencyId != null)
            TextButton.icon(
              onPressed: _resolveEmergency,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text(
                'Resolve',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),

      // -----------------------------------------------------------------------
      // Body
      // -----------------------------------------------------------------------
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF880E4F)),
            )
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng ?? const LatLng(20.5937, 78.9629),
                    zoom: _initialZoom,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                ),

                // Status badge when in SOS mode.
                if (widget.emergencyId != null)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sos, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SOS ACTIVE – Sharing Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _resolveEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resolve Emergency?'),
        content: const Text(
            'Are you safe? This will stop sharing your location.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF880E4F)),
            child:
                const Text('Yes, I\'m safe', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _emergencyService.resolveEmergency();
      Navigator.pop(context);
    }
  }
}
