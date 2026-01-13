import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/sound_constants.dart';

import '../widgets/design_system_buttons.dart';
import 'alarm_result_screen.dart';

class AlarmTriggerScreen extends StatefulWidget {
  final int scheduledHour;
  final int scheduledMinute;
  final String? payload;

  const AlarmTriggerScreen({
    super.key,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.payload,
  });

  @override
  State<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends State<AlarmTriggerScreen> {
  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _soundName = 'default_alarm.mp3';
  double _volume = 0.5;

  // Snooze Settings from Payload
  int _snoozeDurationMinutes = 5;
  int _currentSnoozeCount = 3;

  // Clock
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Snooze State
  bool _isSnoozing = false;
  Timer? _snoozeTimer;
  int _snoozeRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startClock();
    _parsePayload();
    _playAlarmSound();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _snoozeTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  void _parsePayload() {
    if (widget.payload != null) {
      final parts = widget.payload!.split('|');
      // alarm|id|hour|minute|sound|volume|snoozeDuration|snoozeCount
      if (parts.length >= 6) {
        _soundName = parts[4];
        _volume = double.tryParse(parts[5]) ?? 0.5;
        if (parts.length >= 8) {
          _snoozeDurationMinutes = int.tryParse(parts[6]) ?? 5;
          _currentSnoozeCount = int.tryParse(parts[7]) ?? 3;
        }
      }
    }
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);

      if (_soundName.contains('/') ||
          _soundName.contains(Platform.pathSeparator)) {
        if (File(_soundName).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(_soundName));
        }
      } else {
        String assetPath = SoundConstants.soundFileMap[_soundName] ?? '1.mp3';
        await _audioPlayer.play(AssetSource("sounds/$assetPath"));
      }
    } catch (e) {
      debugPrint("Error playing alarm sound: $e");
    }
  }

  void _handleSnooze() {
    if (_currentSnoozeCount <= 0) return;

    _audioPlayer.stop();
    setState(() {
      _isSnoozing = true;
      _currentSnoozeCount--;
      _snoozeRemainingSeconds = _snoozeDurationMinutes * 60;
    });

    _snoozeTimer?.cancel();
    _snoozeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _snoozeRemainingSeconds--;
      });

      if (_snoozeRemainingSeconds <= 0) {
        _stopSnoozeAndRing();
      }
    });
  }

  void _stopSnoozeAndRing() {
    _snoozeTimer?.cancel();
    setState(() {
      _isSnoozing = false;
    });
    _playAlarmSound();
  }

  void _handleWakeUp() {
    _audioPlayer.stop();
    // Navigate to Result Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AlarmResultScreen(
          scheduledHour: widget.scheduledHour,
          scheduledMinute: widget.scheduledMinute,
          payload: widget.payload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String timeString = DateFormat('HH:mm').format(_currentTime);
    final String dateString = DateFormat(
      'M월 d일 EEEE',
      'ko_KR',
    ).format(_currentTime);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Base UI (Background + Clock)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/illusts/illust-alarmBackground.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    // Date
                    Text(
                      dateString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'HYkanB',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Time
                    Text(
                      timeString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontFamily: 'HYcysM',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(flex: 6),

                    // Normal State Buttons (Only visible if NOT snoozing)
                    if (!_isSnoozing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            if (_currentSnoozeCount > 0) ...[
                              GrayButton(
                                label:
                                    "$_snoozeDurationMinutes분 미루기($_currentSnoozeCount회 남음)",
                                width: double.infinity,
                                height: 60,
                                onTap: _handleSnooze,
                              ),
                              const SizedBox(height: 15),
                            ],
                            YellowMainButton(
                              label: "미션 시작하기",
                              width: double.infinity,
                              height: 60,
                              onTap: _handleWakeUp,
                            ),
                          ],
                        ),
                      ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),

          // 2. Snooze Overlay
          if (_isSnoozing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0.50, -0.00),
                    end: const Alignment(0.50, 1.00),
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      const Color(0xFF3F3F3F).withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      const Text(
                        "미루기 중",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'HYkanB',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDuration(_snoozeRemainingSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontFamily: 'HYkanB',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 60),
                      Text(
                        "알람 미루기 $_currentSnoozeCount회 남음",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'HYkanB',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(flex: 2),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: YellowMainButton(
                          label: "미션 시작하기",
                          width: double.infinity,
                          height: 60,
                          onTap: _handleWakeUp,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    // Format: '0:58' instead of '00:58'
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
