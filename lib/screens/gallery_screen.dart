import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import '../models/alarm_history.dart';
import '../providers/history_provider.dart';
import '../theme/app_colors.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HistoryProvider 구독
    final historyProvider = Provider.of<HistoryProvider>(context);
    final historyList = historyProvider.historyList;

    return Scaffold(
      appBar: AppBar(title: const Text("나만의 갤러리")),
      body: historyList.isEmpty
          ? const Center(
              child: Text("아직 수집된 기상 기록이 없습니다.\n알람을 해제하여 기록을 모아보세요!"),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: historyList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2열 그리드
                childAspectRatio: 0.75, // 카드 비율
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. 캐릭터 아이콘
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(
                              item.characterColorValue,
                            ).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(item.characterColorValue),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(item.characterColorValue),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 2. 캐릭터 이름
                        Text(
                          item.characterName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // 3. 점수 Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(item.score),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${item.score}점",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // 4. 날짜/시간
                        Text(
                          DateFormat('MM/dd HH:mm').format(item.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getScoreColor(int score) {
    switch (score) {
      case 1:
        return AppColors.scoreWorst;
      case 2:
        return AppColors.scoreBad;
      case 3:
        return AppColors.scoreNormal;
      case 4:
        return AppColors.scoreGood;
      case 5:
        return AppColors.scorePerfect;
      default:
        return AppColors.lightGray;
    }
  }
}
