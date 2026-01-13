import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/alarm_model.dart';
import '../constants/sound_constants.dart';
import '../theme/app_colors.dart';
import '../widgets/design_system_buttons.dart';
import 'wakeup_mission_screen.dart';

class AlarmTriggerScreen extends StatefulWidget {
  final Alarm alarm;

  const AlarmTriggerScreen({super.key, required this.alarm});

  @override
  State<AlarmTriggerScreen> createState() => _AlarmTriggerScreenState();
}

class _AlarmTriggerScreenState extends State<AlarmTriggerScreen> {
  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _soundName = 'default_alarm.mp3';
  double _volume = 0.5;

  // Clock
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Snooze
  bool _isSnoozing = false;
  Timer? _snoozeTimer;
  final int _snoozeDurationSeconds = 300; // 5 minutes default
  int _snoozeRemaining = 0;

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
    final payload = widget.alarm.payload;
    if (payload != null) {
      final parts = payload.split('|');
      if (parts.length >= 6) {
        _soundName = parts[4];
        _volume = double.tryParse(parts[5]) ?? 0.5;
      }
    } else {
      _soundName = widget.alarm.soundFileName;
      _volume = widget.alarm.volume;
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
    _audioPlayer.stop();
    setState(() {
      _isSnoozing = true;
      _snoozeRemaining = _snoozeDurationSeconds;
    });

    _snoozeTimer?.cancel();
    _snoozeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _snoozeRemaining--;
      });

      if (_snoozeRemaining <= 0) {
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

  void _handleStartMission() {
    _audioPlayer.stop();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WakeupMissionScreen(
          missionType: widget.alarm.missionType,
          missionDifficulty: widget.alarm.missionDifficulty,
          missionCount: widget.alarm.missionCount,
          alarmId: widget.alarm.id,
          scheduledHour: widget.alarm.hour,
          scheduledMinute: widget.alarm.minute,
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
      body: Container(
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
                const Spacer(flex: 4),

                // Snooze Info or Buttons
                if (_isSnoozing)
                  Column(
                    children: [
                      const Text(
                        "알람 미룸",
                        style: TextStyle(
                          color: AppColors.baseYellow,
                          fontSize: 24,
                          fontFamily: 'HYkanB',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDuration(_snoozeRemaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontFamily: 'HYcysM',
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Option to Cancel Snooze and Wake Up immediately
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: YellowMainButton(
                          label: "지금 기상하기",
                          width: double.infinity,
                          height: 60,
                          onTap: _handleStartMission,
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      children: [
                        // Snooze Button
                        GrayButton(
                          label: "5분 미루기",
                          width: double.infinity,
                          height: 60,
                          onTap: _handleSnooze,
                        ),
                        const SizedBox(height: 15),
                        // Start Mission Button
                        YellowMainButton(
                          label: "미션 시작하기",
                          width: double.infinity,
                          height: 60,
                          onTap: _handleStartMission,
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
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
