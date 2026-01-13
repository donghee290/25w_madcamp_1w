import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart'; // import provider

import '../../models/alarm_history.dart';
import '../../providers/history_provider.dart';
import '../../widgets/design_system_buttons.dart';
import 'package:intl/intl.dart';
import '../../models/alarm_model.dart';
import '../../providers/alarm_provider.dart';

class AlarmResultScreen extends StatefulWidget {
  final int scheduledHour;
  final int scheduledMinute;
  final String? payload;

  const AlarmResultScreen({
    super.key,
    required this.scheduledHour,
    required this.scheduledMinute,
    this.payload,
  });

  @override
  State<AlarmResultScreen> createState() => _AlarmResultScreenState();
}

class _AlarmResultScreenState extends State<AlarmResultScreen> {
  late DateTime dismissalTime;
  late int score;
  late int diffMinutes;
  
  // Random Image
  late String _randomImagePath;
  
  // Confetti / Animation? (Optional, skipping for now)

  // Fetched Alarm Data
  String _alarmLabel = "알람";
  MissionType _missionType = MissionType.math;

  @override
  void initState() {
    super.initState();
    dismissalTime = DateTime.now();
    _calculateScore();
    _selectRandomImage();
    
    // Defer alarm lookup to next frame or simple sync lookup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAlarmDetails();
    });
  }

  void _fetchAlarmDetails() {
    if (widget.payload == null) return;
    
    final parts = widget.payload!.split('|');
    // alarm|id|hour|minute|...
    if (parts.length >= 2) {
      final String id = parts[1];
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
      try {
        final alarm = alarmProvider.alarms.firstWhere((a) => a.id == id);
        setState(() {
          _alarmLabel = alarm.label.isEmpty ? "알람" : alarm.label;
          _missionType = alarm.missionType;
        });
      } catch (e) {
        // Alarm might be deleted or not found
        debugPrint("Alarm not found for Result Screen: $e");
      }
    }
    
    // Parse mission type from payload if available (index 8)
    // Payload: alarm|id|hour|minute|sound|volume|duration|snooze|missionType
    if (parts.length >= 9) {
      try {
        final int missionIndex = int.parse(parts[8]);
        if (missionIndex >= 0 && missionIndex < MissionType.values.length) {
          setState(() {
            _missionType = MissionType.values[missionIndex];
          });
        }
      } catch (e) {
        debugPrint("Error parsing mission type from payload: $e");
      }
    }
  }

  void _calculateScore() {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.scheduledHour,
      widget.scheduledMinute,
    );

    if (scheduledTime.isAfter(dismissalTime)) {
      if (scheduledTime.difference(dismissalTime).inHours > 12) {
        scheduledTime = scheduledTime.subtract(const Duration(days: 1));
      }
    }

    int diff = dismissalTime.difference(scheduledTime).inMinutes;
    if (diff < 0) diff = 0;
    diffMinutes = diff;

    if (diff <= 3) {
      score = 5;
    } else if (diff <= 10) {
      score = 4;
    } else if (diff <= 20) {
      score = 3;
    } else if (diff <= 60) {
      score = 2;
    } else {
      score = 1;
    }
  }

  void _selectRandomImage() {
    final images = [
      'illust-pepe.png',
      'illust-math.png',
      'illust-write.png',
      'illust-shake.png',
      'illust-colors.png',
      'illust-alarm.png',
    ];
    final random = Random();
    _randomImagePath = "assets/illusts/${images[random.nextInt(images.length)]}";
  }
  
  String _getScoreMessage(int score) {
    switch (score) {
      case 5: return "완벽\n해요!";
      case 4: return "훌륭\n해요!";
      case 3: return "좋아\n요!";
      case 2: return "아쉽\n네요";
      case 1: return "지각\n위기";
      default: return "완벽\n해요!";
    }
  }

  String _getMissionIconAsset(MissionType type) {
    return "assets/illusts/illust-${type.name}.png";
  }

  @override
  Widget build(BuildContext context) {
    // Date Formatting
    // "2026년 1월 11일(일)"
    final String dateString = DateFormat('yyyy년 M월 d일(E)', 'ko_KR').format(dismissalTime);
    
    // Time Formatting
    // "11:03 AM" -> separate 11:03 and AM
    final String timeNumbers = DateFormat('hh:mm').format(dismissalTime);
    final String timeAmPm = DateFormat('a').format(dismissalTime);

    // Provide default fallback for label
    final String displayLabel = _alarmLabel; 

    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // TOP TEXT
            const Text(
              '기.상.완.료\n대.다.나.다.너',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28, // 24 -> 28
                fontFamily: 'HYcysM',
                fontWeight: FontWeight.w400,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 20), // 30 -> 20

            // RANDOM IMAGE
            Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: Colors.transparent, // Explicitly transparent
                image: DecorationImage(
                  image: AssetImage(_randomImagePath),
                  fit: BoxFit.contain, // Changed to contain to preserve aspect ratio
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000), // 35% Black
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
              ),
            ),

            const Spacer(flex: 1),

            // INFO SECTION (Row)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Column: Date, Time, Title
                  Expanded(
                    flex: 4, // Increase flex to prevent overflow with larger text
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          dateString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // 16 -> 20
                            fontFamily: 'HYkanB',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2), // 5 -> 2
                        // Time
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              timeNumbers,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36, // 32 -> 36
                                fontFamily: 'HYcysM',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              timeAmPm,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28, // 24 -> 28
                                fontFamily: 'HYcysM',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2), // 5 -> 2
                        // Title
                        Text(
                          displayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24, // 20 -> 24
                            fontFamily: 'HYkanM',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Column: Mission Icon, Score
                  Expanded(
                    flex: 3, // Increase flex area
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                         // Mission Icon
                         Container(
                           width: 64, // 54 -> 64
                           height: 68, // 58 -> 68
                           margin: const EdgeInsets.only(right: 10),
                           decoration: BoxDecoration(
                             image: DecorationImage(
                               image: AssetImage(_getMissionIconAsset(_missionType)),
                               fit: BoxFit.contain,
                             ),
                           ),
                         ),
                         // Score Text
                         // Use Flexible to allow wrapping if really needed, but try to keep it 1 line or 2
                         Flexible(
                           child: Text(
                             _getScoreMessage(score),
                             style: const TextStyle(
                               color: Color(0xFFF9E000), // Yellow
                               fontSize: 28, // 24 -> 28
                               fontFamily: 'HYkanB',
                               fontWeight: FontWeight.w400,
                               height: 1.2
                             ),
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: YellowMainButton(
                label: "기상 완료!",
                width: double.infinity,
                height: 60,
                onTap: () async {
                   // Save History Logic
                   final historyEntry = AlarmHistory(
                     timestamp: dismissalTime,
                     score: score,
                     scheduledHour: widget.scheduledHour,
                     scheduledMinute: widget.scheduledMinute,
                     characterName: "랜덤", 
                     characterColorValue: Colors.blue.toARGB32(),
                     imagePath: _randomImagePath,
                   );

                   await Provider.of<HistoryProvider>(
                     context,
                     listen: false,
                   ).addHistory(historyEntry);

                   if (context.mounted) {
                     Navigator.of(context).pop(); 
                   }
                },
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
