import 'package:shake/shake.dart';
import 'package:flutter/foundation.dart';

class ShakeService {
  ShakeDetector? _detector;

  /// Initializes the shake detector.
  /// [onShakeSOS] will be called when 3 shakes are detected.
  void initialize(VoidCallback onShakeSOS) {
    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        debugPrint('Shake detected!');
        onShakeSOS();
      },
      shakeThresholdGravity: 2.7,
      shakeCountResetTime: 3000,
      shakeSlopTimeMS: 500,
      minimumShakeCount: 3,
    );
    debugPrint('ShakeService initialized.');
  }

  void stopListening() {
    _detector?.stopListening();
    debugPrint('ShakeService stopped listening.');
  }

  void startListening() {
    _detector?.startListening();
    debugPrint('ShakeService started listening.');
  }
}
