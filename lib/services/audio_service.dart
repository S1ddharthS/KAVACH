import 'dart:io';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _audioPath;

  Future<void> startEmergencyRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );
        print('Emergency audio recording started.');
      }
    } catch (e) {
      print('Error recording audio: $e');
    }
  }

  Future<String?> stopAndUploadRecording(String userId, String emergencyId) async {
    try {
      if (await _audioRecorder.isRecording()) {
        final path = await _audioRecorder.stop();
        print('Emergency audio recording stopped. File at: $path');
        
        if (path != null) {
          File file = File(path);
          Reference ref = _storage.ref().child('emergencies/$userId/$emergencyId/audio.m4a');
          UploadTask uploadTask = ref.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          print('Emergency audio uploaded successfully: $downloadUrl');
          return downloadUrl;
        }
      }
    } catch (e) {
      print('Error uploading audio: $e');
    }
    return null;
  }
}
