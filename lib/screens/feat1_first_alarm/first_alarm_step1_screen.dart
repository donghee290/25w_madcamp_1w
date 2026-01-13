import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/missions/mission_step_badge.dart';
import 'first_alarm_step2_screen.dart';

class FirstAlarmStep1Screen extends StatefulWidget {
  const FirstAlarmStep1Screen({super.key});

  @override
  State<FirstAlarmStep1Screen> createState() => _FirstAlarmStep1ScreenState();
}

class _FirstAlarmStep1ScreenState extends State<FirstAlarmStep1Screen> {
  int _selectedHour = 7;
  int _selectedMinute = 0;
  bool _isAm = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    int currentHour = now.hour;
    if (currentHour >= 12) {
      _isAm = false;
      _selectedHour = currentHour == 12 ? 12 : currentHour - 12;
    } else {
      _isAm = true;
      _selectedHour = currentHour == 0 ? 12 : currentHour;
    }
    _selectedMinute = now.minute;
  }

  void _onNext() {
    int hour24 = _selectedHour;
    if (_isAm) {
      if (_selectedHour == 12) hour24 = 0;
    } else {
      if (_selectedHour != 12) hour24 = _selectedHour + 12;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FirstAlarmStep2Screen(
          hour: hour24,
          minute: _selectedMinute,
        ),
      ),
    );
  }

  Widget _buildStepBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MissionStepBadge(step: 1, isActive: true),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 2, isActive: false),
        const SizedBox(width: 12),
        const MissionStepBadge(step: 3, isActive: false),
      ],
    );
  }

  Widget _buildTimePicker() {
    // Shared text styles
    const textStyle = TextStyle(
      fontFamily: 'HYcysM',
      color: AppColors.baseWhite,
      fontSize: 36,
    );
    const amPmStyle = TextStyle(
      fontFamily: 'HYcysM',
      color: AppColors.baseWhite,
      fontSize: 26,
    );

    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour
          SizedBox(
            width: 70,
            child: CupertinoPicker(
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: _selectedHour - 1,
              ),
              onSelectedItemChanged: (idx) {
                setState(() => _selectedHour = idx + 1);
              },
              children: List.generate(
                12,
                (index) => Center(child: Text("${index + 1}", style: textStyle)),
              ),
            ),
          ),
          // Minute
          SizedBox(
            width: 70,
            child: CupertinoPicker(
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: _selectedMinute,
              ),
              onSelectedItemChanged: (idx) {
                setState(() => _selectedMinute = idx);
              },
              children: List.generate(
                60,
                (index) => Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: textStyle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // AM/PM
          SizedBox(
            width: 70,
            child: CupertinoPicker(
              itemExtent: 50,
              scrollController: FixedExtentScrollController(
                initialItem: _isAm ? 0 : 1,
              ),
              onSelectedItemChanged: (idx) {
                setState(() => _isAm = idx == 0);
              },
              children: const [
                Center(child: Text("AM", style: amPmStyle)),
                Center(child: Text("PM", style: amPmStyle)),
              ],
            ),
          ),
        ],
      ),
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
             // Step Badges
             _buildStepBadges(),
             const SizedBox(height: 40),
             
             // Title
             const Text(
               "알람을 언제 울려줄까?",
               style: TextStyle(
                 color: AppColors.baseWhite,
                 fontSize: 24,
                 fontFamily: 'HYcysM',
                 fontWeight: FontWeight.w400,
               ),
             ),
             const SizedBox(height: 40),
             
             // Time Picker
             _buildTimePicker(),
             
             const Spacer(),
             
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
