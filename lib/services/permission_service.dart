import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bullshit/services/notification_service.dart';

class PermissionService extends ChangeNotifier {
  PermissionService();

  final NotificationService _notificationService = NotificationService();

  bool _isRequesting = false;
  bool get isRequesting => _isRequesting;

  Future<bool> requestAllInOrder() async {
    if (_isRequesting) return false;
    _isRequesting = true;
    notifyListeners();

    try {
      //1. Notification
      await _notificationService.requestPermissions();
      final notiOk = (await Permission.notification.status).isGranted;
      if (!notiOk) return false;

      //2. Microphone
      final micOk = (await Permission.microphone.request()).isGranted;
      if (!micOk) return false;

      //3. Camera
      final camOk = (await Permission.camera.request()).isGranted;
      if (!camOk) return false;

      //4. Overlay
      if (Platform.isAndroid) {
        await Permission.systemAlertWindow.request();
        final overlayOk = (await Permission.systemAlertWindow.status).isGranted;
        if (!overlayOk) return false;
      }

      //5. Exact Alarm
      if (Platform.isAndroid) {
        await Permission.scheduleExactAlarm.request();
        final exactOk = (await Permission.scheduleExactAlarm.status).isGranted;
        if (!exactOk) return false;
      }

      return true;
    } finally {
      _isRequesting = false;
      notifyListeners();
    }
  }

  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}
