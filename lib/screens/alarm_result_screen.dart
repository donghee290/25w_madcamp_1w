import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart'; // import provider
import '../models/alarm_history.dart';
import '../providers/history_provider.dart';

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
  late String characterName;
  late Color characterColor;
  late int diffMinutes;

  @override
  void initState() {
    super.initState();
    dismissalTime = DateTime.now();
    _calculateScore();
    _selectRandomCharacter();
  }

  void _calculateScore() {
    // 1. 오늘 날짜의 예정된 시간 생성
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.scheduledHour,
      widget.scheduledMinute,
    );

    // 만약 dismissal이 예정 시간보다 *이전*이라면 (하루 전 등의 케이스),
    // 혹은 dismissal이 너무 늦어서 *다음날*로 인식될 수도 있는데,
    // 여기선 단순하게 일(day) 차이 보정은 생략하고, 시/분 차이로만 비교하거나
    // 가장 가까운 과거의 scheduledTime을 찾는 로직이 필요할 수 있음.
    // MVP: 일단 같은 날로 가정하되, scheduledTime이 미래라면(=새벽 알람을 전날 밤에 껐거나 등) 하루 뺌
    if (scheduledTime.isAfter(dismissalTime)) {
      if (scheduledTime.difference(dismissalTime).inHours > 12) {
         scheduledTime = scheduledTime.subtract(const Duration(days: 1));
      }
    } else {
        // scheduledTime이 dismissalTime보다 과거인 경우 (정상)
        // 만약 차이가 너무 크다면(23시간 등) 어제 알람일 수 있으니 보정 필요할 수 있으나 생략
    }

    // 시간 차이 계산 (분 단위, 절대값)
    // 늦게 일어난 경우만 따지므로 dismissal - scheduled
    // 일찍 일어난 경우는 0분 지연으로 처리
    int diff = dismissalTime.difference(scheduledTime).inMinutes;
    if (diff < 0) diff = 0; 
    
    diffMinutes = diff;

    // 점수 로직 (반대로 수정: 빨리 일어날수록 높은 점수)
    // 3이하 : 5점 (완벽)
    // 3-10 : 4점 (좋음)
    // 10-20 : 3점 (보통)
    // 20-60 : 2점 (나쁨)
    // 60이상 : 1점 (최악)
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

  void _selectRandomCharacter() {
    // 임시 캐릭터 로직: 랜덤 색상 + 이름
    final random = Random();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    final names = ["파이리", "꼬부기", "이상해씨", "피카츄", "잠만보"];

    int index = random.nextInt(colors.length);
    characterColor = colors[index];
    characterName = names[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("기상 결과")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 캐릭터 일러스트 (Placeholder)
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: characterColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: characterColor, width: 3),
                ),
                child: Icon(Icons.person, size: 80, color: characterColor),
              ),
              const SizedBox(height: 10),
              Text(
                "파트너: $characterName",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // 2. 정보 표시
              _buildInfoRow("기상 예정 시각",
                  "${widget.scheduledHour.toString().padLeft(2, '0')}:${widget.scheduledMinute.toString().padLeft(2, '0')}"),
              _buildInfoRow("실제 해제 시각",
                  "${dismissalTime.hour.toString().padLeft(2, '0')}:${dismissalTime.minute.toString().padLeft(2, '0')}"),
              _buildInfoRow("지연 시간", "$diffMinutes 분"),
              
              const Divider(height: 40),

              // 3. 점수
              const Text("기상 점수", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text(
                "$score 점",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
              Text(
                _getScoreMessage(score),
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // 저장 로직 (HistoryProvider)
                  final historyEntry = AlarmHistory(
                    timestamp: dismissalTime,
                    score: score,
                    scheduledHour: widget.scheduledHour,
                    scheduledMinute: widget.scheduledMinute,
                    characterName: characterName,
                    characterColorValue: characterColor.toARGB32(),
                  );

                  await Provider.of<HistoryProvider>(context, listen: false)
                      .addHistory(historyEntry);

                  if (context.mounted) {
                    Navigator.of(context).pop(); // 홈으로
                  }
                },
                child: const Text("확인 (갤러리에 저장)"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    switch (score) {
      case 5: return Colors.blue;       // 완벽
      case 4: return Colors.green;      // 좋음
      case 3: return Colors.orange;     // 보통
      case 2: return Colors.deepOrange; // 나쁨
      case 1: return Colors.red;        // 최악
      default: return Colors.black;
    }
  }

  String _getScoreMessage(int score) {
     switch (score) {
       case 5: return "완벽해요! 상쾌한 아침입니다.";
      case 4: return "좋아요! 조금만 더 일찍 일어나볼까요?";
      case 3: return "나쁘지 않아요.";
      case 2: return "피곤하신가요? 힘내세요!";
      case 1: return "지각 위기! 다음엔 꼭 일찍 일어나요.";
      default: return "";
    }
  }
}
