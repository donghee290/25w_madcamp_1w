import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:android_intent_plus/android_intent_plus.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';

class AlarmManagerService {
  static final AlarmManagerService _instance = AlarmManagerService._internal();

  factory AlarmManagerService() {
    return _instance;
  }

  AlarmManagerService._internal();

  Future<void> init() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
  }

  // 알람 예약
  Future<void> scheduleAlarm({
    required int alarmId,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (Platform.isAndroid) {
      // Android: AlarmManager 사용
       await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        alarmCallback, // Static function
        exact: true,
        wakeup: true, // Wake up the device
        alarmClock: true, // Show in status bar as alarm
        allowWhileIdle: true,
        rescheduleOnReboot: true,
        params: payload != null ? {'payload': payload} : null,
      );
    } else {
      // iOS: Fallback to NotificationService (handled by Caller primarily)
    }
  }

  // 알람 취소
  Future<void> cancelAlarm(int alarmId) async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.cancel(alarmId);
    }
  }

  // --- Background Callback ---
  @pragma('vm:entry-point')
  static void alarmCallback(int id, Map<String, dynamic> params) async {
    // 1. Launch App (Full Screen)
    // This intent brings the app to the foreground if running, or starts it if not.
    // 'FLAG_ACTIVITY_NEW_TASK' is required effectively for starting from background context.
    // 'FLAG_ACTIVITY_REORDER_TO_FRONT' or 'CLEAR_TOP' helps bring existing task to front.
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      componentName: 'com.example.bullshit/.MainActivity',
      flags: [
        Flag.FLAG_ACTIVITY_NEW_TASK, 
        Flag.FLAG_ACTIVITY_REORDER_TO_FRONT,
        Flag.FLAG_ACTIVITY_SINGLE_TOP,
      ],
      arguments: params, // Pass payload if possible (Intent extras)
    );
    await intent.launch();

    // 2. Also triggered logic
    // Even if the app launches, we might want to ensure the notification sound plays 
    // or the app detects the alarm.
    // However, simply launching the app is the goal.
    // The App's main logic should check "Why was I woken up?".
    // OR we can use NotificationService to show a notification as a backup.
    
    // Note: To show notification here, we must initialize NotificationService again 
    // because this is a separate isolate.
  }
}
