import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/design_system_buttons.dart';

class CreateAlarmScreen extends StatefulWidget {
  final Alarm? alarm;

  const CreateAlarmScreen({super.key, this.alarm});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  late DateTime _selectedTime;
  final TextEditingController _labelController = TextEditingController();
  List<int> _selectedWeekdays = []; 
  bool _isVibration = true;
  int _snoozeDuration = 5; 
  int _snoozeCount = 3;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      final a = widget.alarm!;
      final now = DateTime.now();
      _selectedTime = DateTime(now.year, now.month, now.day, a.hour, a.minute);
      _labelController.text = a.label;
      _selectedWeekdays = List.from(a.weekdays);
      _isVibration = a.isVibration;
      _snoozeDuration = a.duration;
      _snoozeCount = a.snoozeCount;
    } else {
      final now = DateTime.now();
      _selectedTime = now.add(const Duration(minutes: 1));
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _saveAlarm() {
    final provider = Provider.of<AlarmProvider>(context, listen: false);

    if (provider.hasDuplicateAlarm(_selectedTime.hour, _selectedTime.minute) && widget.alarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("이미 동일한 시간에 설정된 알람이 있습니다."))
      );
      // Allow duplicate edit if it's the same ID? 
      // The simple duplicate check might catch itself. 
      // Provider logic usually needs to ignore self. 
      // Assuming naive check for now, returning if duplicate found on NEW creation.
      if (widget.alarm == null) return;
    }

    final String id = widget.alarm?.id ?? DateTime.now().toString();

    final newAlarm = Alarm(
      id: id,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      label: _labelController.text,
      isEnabled: true,
      weekdays: _selectedWeekdays,
      isVibration: _isVibration,
      duration: _snoozeDuration,
      snoozeCount: _snoozeCount,
    );

    if (widget.alarm != null) {
      provider.updateAlarm(newAlarm);
    } else {
      provider.addAlarm(newAlarm);
    }
    Navigator.of(context).pop();
  }

  Widget _buildTimePicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.baseGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              color: AppColors.baseWhite,
              fontSize: 24,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: _selectedTime,
          use24hFormat: false,
          onDateTimeChanged: (DateTime newTime) {
            setState(() {
              _selectedTime = newTime;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLabelInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "알람 이름",
          style: TextStyle(color: AppColors.lightGray, fontSize: 14, fontFamily: 'HYkanM'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelController,
          style: const TextStyle(color: AppColors.baseWhite),
          decoration: InputDecoration(
            hintText: "기상, 운동 등",
            hintStyle: TextStyle(color: AppColors.baseWhite.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.baseGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    const days = ["월", "화", "수", "목", "금", "토", "일"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "반복 요일",
          style: TextStyle(color: AppColors.lightGray, fontSize: 14, fontFamily: 'HYkanM'),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayIndex = index + 1; // 1~7
            final isSelected = _selectedWeekdays.contains(dayIndex);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedWeekdays.remove(dayIndex);
                  } else {
                    _selectedWeekdays.add(dayIndex);
                  }
                  _selectedWeekdays.sort();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.baseYellow : AppColors.baseGray,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? null : Border.all(color: AppColors.lightGray, width: 1),
                ),
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.baseBlue : AppColors.baseWhite,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HYkanB',
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOptionsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.baseGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildSwitchOption("진동", _isVibration, (val) => setState(() => _isVibration = val)),
          const Divider(height: 1, color: AppColors.subButtonBorder),
          ListTile(
            title: const Text("미루기 (Snooze)", style: TextStyle(color: AppColors.baseWhite, fontFamily: 'HYkanM')),
            trailing: DropdownButton<int>(
              dropdownColor: AppColors.baseGray,
              value: _snoozeDuration,
              style: const TextStyle(color: AppColors.baseWhite, fontFamily: 'HYkanM'),
              iconEnabledColor: AppColors.baseYellow,
              underline: Container(),
              items: [1, 3, 5, 10, 15]
                  .map((e) => DropdownMenuItem(value: e, child: Text("$e분")))
                  .toList(),
              onChanged: (val) => setState(() => _snoozeDuration = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchOption(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      activeThumbColor: AppColors.baseYellow,
      activeTrackColor: AppColors.baseYellow.withValues(alpha: 0.5),
      inactiveThumbColor: AppColors.lightGray,
      inactiveTrackColor: AppColors.baseBlack,
      title: Text(title, style: const TextStyle(color: AppColors.baseWhite, fontFamily: 'HYkanM')),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseBlack,
      appBar: AppBar(
        backgroundColor: AppColors.baseBlack,
        elevation: 0,
        leading: const BackButton(color: AppColors.baseWhite),
        title: const Text("알람 추가", style: TextStyle(color: AppColors.baseWhite, fontFamily: 'HYcysM')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildTimePicker(),
            const SizedBox(height: 25),
            _buildLabelInput(),
            const SizedBox(height: 25),
            _buildWeekdaySelector(),
            const SizedBox(height: 25),
            _buildOptionsList(),
            const SizedBox(height: 40),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: GrayButton(
                    label: "취소",
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: YellowMainButton(
                    label: "저장",
                    onTap: _saveAlarm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
