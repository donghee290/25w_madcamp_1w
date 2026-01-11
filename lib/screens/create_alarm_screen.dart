import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';

class CreateAlarmScreen extends StatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  // 1. Time State
  late DateTime _selectedTime;

  // 2. Options State
  final TextEditingController _labelController = TextEditingController();
  List<int> _selectedWeekdays = []; // 1: Mon ... 7: Sun
  bool _isVibration = true;
  int _snoozeDuration = 5; // minutes
  int _snoozeCount = 3;

  @override
  void initState() {
    super.initState();
    // Default time: Next minute (for easy testing) or next hour
    final now = DateTime.now();
    _selectedTime = now.add(const Duration(minutes: 1));
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  // --- Logic ---
  void _saveAlarm() {
    final provider = Provider.of<AlarmProvider>(context, listen: false);

    // 1. Check Duplicate
    if (provider.hasDuplicateAlarm(_selectedTime.hour, _selectedTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이미 동일한 시간에 설정된 알람이 있습니다.")),
      );
      return;
    }

    // 2. Create Object
    final newAlarm = Alarm(
      id: DateTime.now().toString(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      label: _labelController.text,
      isEnabled: true,
      weekdays: _selectedWeekdays,
      isVibration: _isVibration,
      duration: _snoozeDuration,
      snoozeCount: _snoozeCount,
    );

    // 3. Save & Pop
    provider.addAlarm(newAlarm);
    Navigator.of(context).pop();
  }

  // --- UI Components (Modular for easy maintenance) ---

  Widget _buildTimePicker() {
    return SizedBox(
      height: 200,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: _selectedTime,
        use24hFormat: true,
        onDateTimeChanged: (DateTime newTime) {
          setState(() {
            _selectedTime = newTime;
          });
        },
      ),
    );
  }

  Widget _buildLabelInput() {
    return TextField(
      controller: _labelController,
      decoration: const InputDecoration(
        labelText: "알람 이름",
        hintText: "기상, 운동 등",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.label),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    const days = ["월", "화", "수", "목", "금", "토", "일"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("반복 요일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.grey[200],
                ),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
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
    return Column(
      children: [
        SwitchListTile(
          title: const Text("진동"),
          value: _isVibration,
          onChanged: (val) => setState(() => _isVibration = val),
          secondary: const Icon(Icons.vibration),
        ),
        ListTile(
          leading: const Icon(Icons.snooze),
          title: const Text("미루기 (Snooze)"),
          trailing: DropdownButton<int>(
            value: _snoozeDuration,
            items: [1, 3, 5, 10, 15].map((e) => DropdownMenuItem(value: e, child: Text("$e분"))).toList(),
            onChanged: (val) => setState(() => _snoozeDuration = val!),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("알람 추가"),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _saveAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "저장",
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTimePicker(),
            const SizedBox(height: 30),
            _buildLabelInput(),
            const SizedBox(height: 30),
            _buildWeekdaySelector(),
            const SizedBox(height: 20),
            const Divider(),
            _buildOptionsList(),
          ],
        ),
      ),
    );
  }
}
