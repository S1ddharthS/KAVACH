import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  /// Initializes the voice recognition service and starts listening
  /// for the phrase "HELP ME".
  /// [onHelpPhraseDetected] is called when the trigger phrase is heard.
  Future<void> initialize(VoidCallback onHelpPhraseDetected) async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('VoiceService status: $status');
          // If listening stops unexpectedly and we didn't manually stop it, restart it
          if (status == 'done' && _isListening) {
             _startListening(onHelpPhraseDetected);
          }
        },
        onError: (errorNotification) {
          debugPrint('VoiceService error: ${errorNotification.errorMsg}');
          if (_isListening) {
            _startListening(onHelpPhraseDetected);
          }
        },
      );

      if (available) {
        debugPrint('VoiceService initialized successfully. Listening...');
        _startListening(onHelpPhraseDetected);
      } else {
        debugPrint('Speech recognition is not available on this device');
      }
    } catch (e) {
      debugPrint('Error initializing VoiceService: $e');
    }
  }

  void _startListening(VoidCallback onHelpPhraseDetected) {
    _isListening = true;
    _speech.listen(
      onResult: (result) {
        final recognizedWords = result.recognizedWords.toLowerCase();
        debugPrint('VoiceService recognized words: $recognizedWords');
        
        if (recognizedWords.contains("help me")) {
          debugPrint('Trigger phrase detected!');
          onHelpPhraseDetected();
          stopListening(); // Optionally stop listening after triggered
        }
      },
      listenFor: const Duration(minutes: 5), // Listen for long periods
      pauseFor: const Duration(seconds: 10), // Pause tolerance
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void stopListening() {
    _isListening = false;
    _speech.stop();
    debugPrint('VoiceService stopped listening.');
  }
}
