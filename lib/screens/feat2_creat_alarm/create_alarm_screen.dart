import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_model.dart';
import '../../providers/alarm_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/custom_switch.dart';
import '../../widgets/sound_selection_popup.dart';
import '../../widgets/mission_selection_popup.dart';
import '../../constants/sound_constants.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateAlarmScreen extends StatefulWidget {
  final Alarm? alarm;

  const CreateAlarmScreen({super.key, this.alarm});

  @override
  State<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends State<CreateAlarmScreen> {
  int _selectedHour = 7;
  int _selectedMinute = 0;
  bool _isAm = true;

  final TextEditingController _labelController = TextEditingController();
  List<int> _selectedWeekdays = [];
  bool _isOnce = false;

  //Sound & Mission
  double _volume = 0.5;
  String _soundName = "Good Morning(LG)";
  bool _isSoundSliderVisible = false;
  String _missionName = "수학 문제";
  MissionType _missionType = MissionType.math;
  String? _missionPayload;
  int _missionDifficulty = 1;
  int _missionCount = 2;

  //Settings
  bool _isVibration = true;
  int _duration = 1;
  bool _isSnoozeOn = true;
  int _snoozeCount = 1;

  ui.Image? _sliderThumbImage;

  static const TextStyle _subTitleStyle = TextStyle(
    color: AppColors.baseWhite,
    fontSize: 15,
    fontFamily: 'HYkanB',
  );

  String _missionTitleOf(MissionType type) {
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

  String _missionIconOf(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
  }

  String _difficultyLabel(MissionType type, int diff) {
    if (type == MissionType.math) {
      switch (diff) {
        case 1:
          return "매우 쉬움";
        case 2:
          return "쉬움";
        case 3:
          return "보통";
        case 4:
          return "어려움";
        case 5:
          return "매우 어려움";
        default:
          return "매우 쉬움";
      }
    }
    if (type == MissionType.colors || type == MissionType.write) {
      switch (diff) {
        case 1:
          return "쉬움";
        case 2:
          return "보통";
        case 3:
          return "어려움";
        default:
          return "쉬움";
      }
    }
    return "-"; //MissionType.shake
  }

  String _missionSummaryLine() {
    if (_missionType == MissionType.shake) {
      return "횟수: $_missionCount회";
    }
    return "난이도: ${_difficultyLabel(_missionType, _missionDifficulty)}    횟수: $_missionCount회";
  }

  @override
  void initState() {
    super.initState();
    _loadSliderThumbImage();

    if (widget.alarm != null) {
      final a = widget.alarm!;
      _labelController.text = a.label;
      _soundName = a.soundFileName;
      _selectedWeekdays = List.from(a.weekdays);
      _isVibration = a.isVibration;
      _duration = a.duration;
      _snoozeCount = a.snoozeCount;
      _isSnoozeOn = a.snoozeCount > 0;

      _missionType = a.missionType;
      _missionPayload = a.payload;
      _missionDifficulty = a.missionDifficulty;
      _missionCount = a.missionCount;
      _missionName = _missionTitleOf(_missionType);

      //Time Logic
      if (a.hour >= 12) {
        _isAm = false;
        _selectedHour = a.hour == 12 ? 12 : a.hour - 12;
      } else {
        _isAm = true;
        _selectedHour = a.hour == 0 ? 12 : a.hour;
      }
      _selectedMinute = a.minute;

      if (_selectedWeekdays.isEmpty) {
        _isOnce = true;
      }
    } else {
      //Default: Current System Time
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

      //Default Weekdays: Empty implies "한번만" logic
      _selectedWeekdays = [];
      _isOnce = true;
    }
  }

  Future<void> _loadSliderThumbImage() async {
    try {
      final ByteData data = await rootBundle.load(
        'assets/illusts/illust-controller.png',
      );
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _sliderThumbImage = fi.image;
        });
      }
    } catch (e) {
      debugPrint("Error loading slider thumb: $e");
    }
  }

  // Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _labelController.dispose();
    // Safe disposal
    _audioPlayer.stop().catchError((e) {
      debugPrint("Error stopping audio on dispose: $e");
    });
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundName) async {
    try {
      await _audioPlayer.stop();

      String actualSoundName = soundName;
      if (actualSoundName.startsWith("녹음한 음원 : ")) {
        actualSoundName = actualSoundName.replaceFirst("녹음한 음원 : ", "");
      } else if (actualSoundName.startsWith("나의 음원 : ")) {
        actualSoundName = actualSoundName.replaceFirst("나의 음원 : ", "");
      }

      if (actualSoundName.contains('/') ||
          actualSoundName.contains(Platform.pathSeparator)) {
        // Custom recording path
        if (File(actualSoundName).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(actualSoundName));
        }
      } else {
        // Ensure mapping exists or fallback
        String assetPath =
            SoundConstants.soundFileMap[actualSoundName] ?? '1.mp3';

        // AssetSource automatically looks in 'assets/'.
        // Our map values are just filenames like '1.mp3', so we prepend 'sounds/'.
        await _audioPlayer.play(AssetSource("sounds/$assetPath"));
      }
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _saveAlarm() {
    final provider = Provider.of<AlarmProvider>(context, listen: false);

    // Convert back to 24h
    int hour24 = _selectedHour;
    if (_isAm) {
      if (_selectedHour == 12) hour24 = 0;
    } else {
      if (_selectedHour != 12) hour24 = _selectedHour + 12;
    }

    // If "Once" is checked, finalWeekdays is empty.
    final finalWeekdays = _isOnce ? <int>[] : _selectedWeekdays;

    final String id = widget.alarm?.id ?? DateTime.now().toString();

    final newAlarm = Alarm(
      id: id,
      hour: hour24,
      minute: _selectedMinute,
      label: _labelController.text,
      isEnabled: true,
      weekdays: finalWeekdays,
      isVibration: _isVibration,
      duration: _duration,
      snoozeCount: _isSnoozeOn ? _snoozeCount : 0,
      soundFileName: _soundName,
      missionType: _missionType,
      missionDifficulty: _missionDifficulty,
      missionCount: _missionCount,
      payload: _missionPayload,
      volume: _volume,
    );

    if (widget.alarm != null) {
      provider.updateAlarm(newAlarm);
    } else {
      provider.addAlarm(newAlarm);
    }
    Navigator.of(context).pop();
  }

  // --- UI Widgets ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            widget.alarm == null ? "기상 생성하기" : "기상 수정하기",
            style: const TextStyle(
              fontFamily: 'HYcysM',
              fontSize: 32,
              color: AppColors.baseWhite,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.black, thickness: 2, height: 2),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    // Custom Wheel Picker: Hour | Minute | AM/PM
    // Font: Serif (HYcysM)
    const textStyle = TextStyle(
      fontFamily: 'HYcysM',
      color: AppColors.baseWhite,
      fontSize: 36, // 32 -> 36
    );
    const amPmStyle = TextStyle(
      fontFamily: 'HYcysM',
      color: AppColors.baseWhite,
      fontSize: 26, // 24 -> 26
    );

    return Container(
      height: 140, // 150 -> 140
      margin: const EdgeInsets.symmetric(vertical: 20),
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
                (index) =>
                    Center(child: Text("${index + 1}", style: textStyle)),
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

  Widget _buildWeekdaySection() {
    // "한번만" Checkbox + Weekdays
    return Column(
      children: [
        // Checkbox Row
        GestureDetector(
          onTap: () {
            setState(() {
              _isOnce = !_isOnce;
              // If we re-check 'Once', maybe clear weekdays?
              // Or keep them but treat as empty? Logic handles it.
              // If we uncheck 'Once', keep selected or what?
              // User requirement: Default is empty.
            });
          },
          child: Row(
            children: [
              // Custom Checkbox
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD9D9D9),
                    width: 1.5,
                  ),
                  color: _isOnce
                      ? const Color(0xFF404040)
                      : Colors
                            .transparent, // Fill with dark grey if checked like img
                ),
                child: _isOnce
                    ? const Icon(
                        Icons.check,
                        size: 20,
                        color: Color(0xFFD9D9D9),
                      )
                    : null,
              ),
              const Text(
                "한번만",
                style: TextStyle(
                  color: Color(0xFFD9D9D9),
                  fontFamily: 'HYkanM',
                  fontSize:
                      14, // 12/14 ->? Wait, "한번만" was 14. Let's make it 16?
                  // Original: 14. Plan: Increase by 2. -> 16.
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // 15 -> 12
        // Weekdays
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["일", "월", "화", "수", "목", "금", "토"].asMap().entries.map((
            entry,
          ) {
            final idx = entry.key;
            final label = entry.value;
            final int weekdayId = (idx == 0) ? 7 : idx;

            final isSelected =
                !_isOnce && _selectedWeekdays.contains(weekdayId);

            return GestureDetector(
              onTap: _isOnce
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _selectedWeekdays.remove(weekdayId);
                        } else {
                          _selectedWeekdays.add(weekdayId);
                        }
                      });
                    },
              child: Opacity(
                opacity: _isOnce ? 0.3 : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: null, // Always use gradient
                    gradient: isSelected
                        ? AppColors.secondaryGradient
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFF6E6E7E)),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.baseBlue
                          : const Color(0xFFD9D9D9),
                      fontFamily: 'HYkanB',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBlueBox(
    String title,
    String content,
    String iconPath, {
    VoidCallback? onTap,
    VoidCallback? onBoxTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.baseWhite,
                fontSize: 15,
                fontFamily: 'HYkanB',
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: const Text(
                "설정하러 가기",
                style: TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.baseWhite, // NEW
                  fontFamily: 'HYkanM',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onBoxTap,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.gradSkyblue,
              borderRadius: BorderRadius.circular(0), // Sharp rect
              border: Border.all(color: const Color(0xFF396DA9), width: 2),
            ),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Image.asset(iconPath, width: 32, height: 32),
                const SizedBox(width: 15),
                // FIX: Wrapped in Expanded and added overflow handling
                Expanded(
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Color(0xFF5882B4),
                      fontSize: 18, // 16 -> 18
                      fontFamily: 'HYkanB',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 15,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4E4E5E), Color(0xFF0E0E1E)],
                  ),
                  borderRadius: BorderRadius.circular(7.5), // 15 -> 7.5
                  border: Border.all(color: const Color(0xFF6E6E7E)),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbShape: _CustomThumbShape(image: _sliderThumbImage),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _volume,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _audioPlayer.setVolume(v);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "커스텀 설정",
          style: TextStyle(
            color: AppColors.baseWhite,
            fontSize: 15,
            fontFamily: 'HYkanB',
          ),
        ),
        const SizedBox(height: 12),
        //Vibration
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            children: [
              //Vibration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "진동 울리기",
                    style: TextStyle(
                      color: AppColors.baseWhite,
                      fontSize: 14,
                      fontFamily: 'HYkanM',
                    ),
                  ),
                  CustomSwitch(
                    value: _isVibration,
                    onChanged: (v) => setState(() => _isVibration = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              //Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "미루기 시간",
                    style: TextStyle(
                      color: AppColors.baseWhite,
                      fontSize: 14,
                      fontFamily: 'HYkanM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [1, 3, 5]
                    .map(
                      (d) => _buildSelectButton(
                        "$d분",
                        _duration == d,
                        () => setState(() => _duration = d),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              //Snooze
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "알람 미루기",
                    style: TextStyle(
                      color: AppColors.baseWhite,
                      fontSize: 14,
                      fontFamily: 'HYkanM',
                    ),
                  ),
                  CustomSwitch(
                    value: _isSnoozeOn,
                    onChanged: (v) {
                      setState(() {
                        _isSnoozeOn = v;
                        if (!v) {
                          _snoozeCount = 0;
                        } else {
                          if (_snoozeCount == 0) _snoozeCount = 1;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: _isSnoozeOn ? 1.0 : 0.3,
                child: AbsorbPointer(
                  absorbing: !_isSnoozeOn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3]
                        .map(
                          (c) => _buildSelectButton(
                            "$c회",
                            _snoozeCount == c,
                            () => setState(() => _snoozeCount = c),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: null,
            gradient: isSelected
                ? AppColors.secondaryGradient
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.baseBlue : const Color(0xFFD9D9D9),
              fontFamily: isSelected ? 'HYkanB' : 'HYkanM',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _getSoundDisplayName(String soundName) {
    // 1. Check if it's a known Key (Preset Name)
    if (SoundConstants.soundFileMap.containsKey(soundName)) {
      return soundName;
    }

    // 2. Check if it's a known Value (Filename) -> Logically reverse map
    for (var entry in SoundConstants.soundFileMap.entries) {
      if (entry.value == soundName) {
        return entry.key;
      }
    }

    // 3. Check for specific keys
    if (soundName == SoundConstants.customRecordingKey ||
        soundName == SoundConstants.myAudioKey) {
      return soundName;
    }

    // 4. Check if it's a file path
    if (soundName.contains('/') || soundName.contains(Platform.pathSeparator)) {
      try {
        String fileName = soundName.split(Platform.pathSeparator).last;
        // Regex to clean timestamp: name_timestamp.ext
        final RegExp regex = RegExp(r'^(.*)_(\d+)\.(\w+)');
        final match = regex.firstMatch(fileName);
        if (match != null) {
          return "${match.group(1)}.${match.group(3)}";
        }
        return fileName;
      } catch (e) {
        return "알 수 없는 파일";
      }
    }

    // 5. Fallback
    return soundName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E),
      body: SafeArea(
        child: Column(
          children: [
            //Header
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.baseWhite,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Label Input
                    const SizedBox(height: 12),
                    const Text("기상 이름", style: _subTitleStyle),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.baseWhite,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _labelController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'HYkanM',
                        ),
                        decoration: const InputDecoration(
                          hintText: "기상명을 입력해주세요.",
                          hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("기상 시간", style: _subTitleStyle),

                    _buildTimePicker(),

                    _buildWeekdaySection(),

                    const SizedBox(height: 25),

                    _buildBlueBox(
                      "기상 사운드",
                      _getSoundDisplayName(_soundName),
                      "assets/illusts/illust-sound.png",
                      onBoxTap: () {
                        setState(() {
                          // Toggle slider visibility
                          _isSoundSliderVisible = !_isSoundSliderVisible;
                        });

                        if (_isSoundSliderVisible) {
                          // If became visible, play sound
                          _playSound(_soundName);
                        } else {
                          // If became hidden, stop sound
                          _audioPlayer.stop();
                        }
                      },
                      onTap: () async {
                        // Stop playing sound when opening popup
                        await _audioPlayer.stop();
                        if (!mounted) return;
                        setState(() {
                          _isSoundSliderVisible = false;
                        });

                        final result = await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => SoundSelectionPopup(
                            initialSound: _soundName,
                            initialVolume: _volume,
                          ),
                        );

                        if (result != null && result is Map) {
                          setState(() {
                            _soundName = result['soundName'];
                            _volume = result['volume'];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Wrap slider in AnimatedSize for show/hide effect
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isSoundSliderVisible
                          ? Column(
                              children: [
                                _buildSlider(),
                                const SizedBox(height: 15),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    _buildBlueBox(
                      "기상 미션",
                      _missionName,
                      _missionIconOf(_missionType),
                      onBoxTap: () {
                        // Optional: Show mission toast or something else?
                        // For now do nothing as requested is only for sound
                      },
                      onTap: () async {
                        // Stop playing sound when opening popup
                        await _audioPlayer.stop();
                        if (!mounted) return;
                        setState(() {
                          _isSoundSliderVisible = false;
                        });

                        final result = await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => MissionSelectionPopup(
                            initialType: _missionType,
                            initialPayload: _missionPayload,
                            initialDifficulty: _missionDifficulty,
                            initialCount: _missionCount,
                          ),
                        );

                        if (result != null && result is Map) {
                          setState(() {
                            _missionType = result['missionType'] as MissionType;
                            _missionDifficulty =
                                result['missionDifficulty'] as int;
                            _missionCount = result['missionCount'] as int;
                            _missionPayload = result['payload'] as String?;
                            _missionName = result['missionName'] as String;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _missionSummaryLine(),
                          style: const TextStyle(
                            color: Color(0xFFD9D9D9),
                            fontSize: 12,
                            fontFamily: 'HYkanM',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildCustomSettings(),

                    const SizedBox(height: 40),
                    YellowMainButton(
                      label: widget.alarm == null ? "기상 생성하기" : "기상 수정하기",
                      onTap: _saveAlarm,
                      width: double.infinity,
                      height: 50,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final ui.Image? image;

  _CustomThumbShape({this.image});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    if (image == null) {
      // Fallback
      final Canvas canvas = context.canvas;
      canvas.drawCircle(center, 15, Paint()..color = Colors.white);
      return;
    }

    final Canvas canvas = context.canvas;

    // Draw image centered at 'center'
    // Target size for thumb: 36x36
    final dst = Rect.fromCenter(center: center, width: 36, height: 36);
    final src = Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );

    canvas.drawImageRect(image!, src, dst, Paint());
  }
}
