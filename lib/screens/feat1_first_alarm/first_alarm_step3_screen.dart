import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';
import '../../models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/design_system_layouts.dart';
// Removed unused button import
import '../../widgets/missions/mission_step_badge.dart';
import '../../widgets/mission_difficulty_selection_popup.dart';
import 'outro_screen.dart';

class FirstAlarmStep3Screen extends StatefulWidget {
  final int hour;
  final int minute;
  final String soundName;
  final double volume;

  const FirstAlarmStep3Screen({
    super.key,
    required this.hour,
    required this.minute,
    required this.soundName,
    required this.volume,
  });

  @override
  State<FirstAlarmStep3Screen> createState() => _FirstAlarmStep3ScreenState();
}

class _FirstAlarmStep3ScreenState extends State<FirstAlarmStep3Screen> {
  // Mission State
  // Removed unused fields: _difficulty, _count, _payload, _selectedType is likely needed for current implementation but was flagged?
  // _selectedType was NOT flagged, but _difficulty etc were because they were only used in _onComplete which was removed? 
  // Ah, I moved logic to `_createAlarmAndProceed`. 
  // Let's re-examine usage.
  
  // Defaults per type (internal tracking)
  final Map<MissionType, int> _difficultyByType = {
    MissionType.math: 1,
    MissionType.colors: 1,
    MissionType.write: 1,
    MissionType.shake: 0,
  };
  final Map<MissionType, int> _countByType = {
    MissionType.math: 2,
    MissionType.colors: 2,
    MissionType.write: 2,
    MissionType.shake: 5,
  };

  final List<MissionType> _types = const [
    MissionType.math,
    MissionType.colors,
    MissionType.write,
    MissionType.shake,
  ];

  String _titleOf(MissionType type) {
    switch (type) {
      case MissionType.math:
        return "수학 문제";
      case MissionType.colors:
        return "색깔 타일 찾기";
      case MissionType.write:
        return "따라쓰기";
      case MissionType.shake:
        return "흔들기";
    }
  }

  String _iconOf(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
  }

  Future<void> _openDetail(MissionType type) async {
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MissionDifficultySelectionPopup(
        type: type,
        initialDifficulty: _difficultyByType[type]!,
        initialCount: _countByType[type]!,
      ),
    );

    if (!mounted) return;

    if (result != null && result is Map) {
      final MissionType newType = result['missionType'] as MissionType? ?? type;
      final int newDifficulty = result['missionDifficulty'] as int? ?? 1;
      final int newCount = result['missionCount'] as int? ?? 1;
      final String? newPayload = result['payload'] as String?;

      // Update cache
      _difficultyByType[newType] = newDifficulty;
      _countByType[newType] = newCount;

      // No need to setState unused variables
      
      // Immediately create alarm and proceed
      _createAlarmAndProceed(newType, newDifficulty, newCount, newPayload);
    }
  }

  Future<void> _createAlarmAndProceed(
    MissionType type,
    int difficulty,
    int count,
    String? payload,
  ) async {
    // 1. Create Alarm Object
    final String id = DateTime.now().toString();
    final newAlarm = Alarm(
      id: id,
      hour: widget.hour,
      minute: widget.minute,
      label: "첫 알람",
      isEnabled: true,
      weekdays: [], // Once
      isVibration: true,
      duration: 1, // Default duration
      snoozeCount: 1, // Default snooze
      soundFileName: widget.soundName,
      volume: widget.volume,
      missionType: type,
      missionDifficulty: difficulty,
      missionCount: count,
      payload: payload,
    );

    // 2. Save via Provider
    await Provider.of<AlarmProvider>(context, listen: false).addAlarm(newAlarm);

    // 3. Navigate to Outro
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const OutroScreen()));
    }
  }

  Widget _buildStepBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MissionStepBadge(step: 1, isActive: false),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 2, isActive: false),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 3, isActive: true),
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
              "기상 미션은 뭘로 할까?",
              style: TextStyle(
                color: AppColors.baseWhite,
                fontSize: 24,
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 30),

            // Mission List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _types.map((type) {
                    // Removed unused isSelected
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SkyblueListItem(
                        onTap: () => _openDetail(type),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 60,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Image.asset(
                                    _iconOf(type),
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      _titleOf(type),
                                      style: const TextStyle(
                                        fontFamily: 'HYkanB',
                                        fontSize: 18,
                                        color: Color(0xFF5882B4),
                                      ),
                                    ),
                                  ),
                                  // Removed Check icon for cleaner look or consistent behavior
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
