import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentPath;
  
  // Stream to listen to recording state
  Stream<bool> get isRecordingStream => _audioRecorder.onStateChanged().map(
    (state) => state == RecordState.record,
  );

  /// Stub for permission check.
  /// User requested to bypass complex logic for now.
  /// Real implementation would request microphone permission.
  Future<bool> hasPermission() async {
    // Temporary bypass: Always return true or minimal check
    // Ideally we should still request permission to avoid crashes on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
       var status = await Permission.microphone.status;
       if (status != PermissionStatus.granted) {
         status = await Permission.microphone.request();
       }
       return status == PermissionStatus.granted;
    }
    return true; // Assume true for desktop/web for now or if stubbed
  }

  /// Starts recording to a temporary file.
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'temp_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentPath = '${tempDir.path}/$fileName';

        // Config: AAC is standard.
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        
        await _audioRecorder.start(config, path: _currentPath!);
        debugPrint("Recording started at $_currentPath");
      } else {
        debugPrint("Recording permission missing");
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  /// Stops recording and returns the file path.
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      debugPrint("Recording stopped. File saved at $path");
      return path;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      return null;
    }
  }

  /// Cancels recording and deletes the temporary file.
  Future<void> cancelRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          debugPrint("Recording cancelled and file deleted.");
        }
      }
    } catch (e) {
      debugPrint("Error cancelling recording: $e");
    } finally {
      _currentPath = null;
    }
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
