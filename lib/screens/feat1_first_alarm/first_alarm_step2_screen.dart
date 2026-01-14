import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/missions/mission_step_badge.dart';
import '../../widgets/sound_selection_list.dart';
import 'first_alarm_step3_screen.dart';

class FirstAlarmStep2Screen extends StatefulWidget {
  final int hour;
  final int minute;

  const FirstAlarmStep2Screen({
    super.key,
    required this.hour,
    required this.minute,
  });

  @override
  State<FirstAlarmStep2Screen> createState() => _FirstAlarmStep2ScreenState();
}

class _FirstAlarmStep2ScreenState extends State<FirstAlarmStep2Screen> {
  String _selectedSound = "카이스트 거위";
  double _volume = 0.5;

  void _onNext() {
    _soundListKey.currentState?.stopAudio();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FirstAlarmStep3Screen(
          hour: widget.hour,
          minute: widget.minute,
          soundName: _selectedSound,
          volume: _volume,
        ),
      ),
    );
  }

  Widget _buildStepBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MissionStepBadge(step: 1, isActive: false),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 2, isActive: true),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 3, isActive: false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Badges
            _buildStepBadges(),
            const SizedBox(height: 40),

            // Title
            const Text(
              "기상 사운드는 뭘로 해줄까?",
              style: TextStyle(
                color: AppColors.baseWhite,
                fontSize: 24,
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),

            // Sound List (Expanded)
            Expanded(
              child: SoundSelectionList(
                key: _soundListKey,
                initialSound: _selectedSound,
                initialVolume: _volume,
                onSelectionChanged: (sound, volume) {
                  setState(() {
                    _selectedSound = sound;
                    _volume = volume;
                  });
                },
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              child: YellowMainButton(
                label: "다음",
                onTap: _onNext,
                width: double.infinity,
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
