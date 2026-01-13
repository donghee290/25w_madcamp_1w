import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import 'alarm_result_screen.dart';
import '../widgets/missions/mission_math.dart';
import '../widgets/missions/mission_colors.dart';

class WakeupMissionScreen extends StatefulWidget {
  final MissionType missionType;
  final int missionDifficulty;
  final int missionCount;
  final String alarmId;

  final int scheduledHour;
  final int scheduledMinute;

  const WakeupMissionScreen({
    super.key,
    required this.missionType,
    required this.missionDifficulty,
    required this.missionCount,
    required this.alarmId,
    required this.scheduledHour,
    required this.scheduledMinute,
  });

  @override
  State<WakeupMissionScreen> createState() => _WakeupMissionScreenState();
}

class _WakeupMissionScreenState extends State<WakeupMissionScreen> {
  late int _remaining;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    _remaining = widget.missionCount;
  }

  void _onMissionSuccess() {
    setState(() {
      _remaining--;
      _round++;
    });

    if (_remaining <= 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AlarmResultScreen(
            scheduledHour: widget.scheduledHour,
            scheduledMinute: widget.scheduledMinute,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _StepHeader(
              step: (widget.missionCount - _remaining) + 1,
              total: widget.missionCount,
            ),
            const SizedBox(height: 24),

            Expanded(child: _buildMissionBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionBody() {
    switch (widget.missionType) {
      case MissionType.math:
        return MissionMath(
          key: ValueKey(_round),
          difficulty: widget.missionDifficulty,
          onSuccess: _onMissionSuccess,
        );
      case MissionType.colors:
        return MissionColors(
          key: ValueKey(_round),
          difficulty: widget.missionDifficulty,
          onSuccess: _onMissionSuccess,
        );
      case MissionType.write:
        return const Center(
          child: Text("write 미션 준비중", style: TextStyle(color: Colors.white)),
        );
      case MissionType.shake:
        return const Center(
          child: Text("shake 미션 준비중", style: TextStyle(color: Colors.white)),
        );
    }
  }
}

class _StepHeader extends StatelessWidget {
  final int step;
  final int total;

  const _StepHeader({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final current = step.clamp(1, total);

    Widget circle(int n) {
      final bool active = n <= current;
      return Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFF7C3AED) : const Color(0xFFD9C7FF),
        ),
        child: Text(
          n.toString().padLeft(2, '0'),
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF5B4B7A),
            fontFamily: 'HYkanB',
            fontSize: 14,
          ),
        ),
      );
    }

    return SizedBox(
      height: 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // 스크롤 막고 싶으면 유지
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(total, (i) {
            final n = i + 1;
            return Padding(
              padding: EdgeInsets.only(right: n == total ? 0 : 12),
              child: circle(n),
            );
          }),
        ),
      ),
    );
  }
}
