import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'providers/alarm_provider.dart';
import 'services/notification_service.dart';

void main() async {
  // [Step 3 검증] Hive 초기화 및 설정
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // 어댑터 등록 (이 부분이 없으면 에러남)
  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(MissionTypeAdapter());

  // 박스 열기
  await Hive.openBox<Alarm>('alarmBox');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AlarmProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestScreen());
  }
}

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // [Step 2 검증] Provider 접근
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Step 2 & 3 검증 테스트")),
      body: Column(
        children: [
          // 1. 상태창
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[200],
            width: double.infinity,
            child: Text(
              "현재 저장된 알람 개수: ${alarmProvider.alarms.length}개",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // 2. 알람 리스트 출력 (DB에서 잘 불러오는지 확인)
          Expanded(
            child: ListView.builder(
              itemCount: alarmProvider.alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarmProvider.alarms[index];
                return ListTile(
                  leading: Icon(
                    alarm.isEnabled ? Icons.alarm_on : Icons.alarm_off,
                    color: alarm.isEnabled ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    "${alarm.hour}시 ${alarm.minute}분 (${alarm.label})",
                  ),
                  subtitle: Text(
                    "ID: ${alarm.id.substring(0, 5)}... / 요일: ${alarm.weekdays}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // 삭제 기능 테스트
                      alarmProvider.deleteAlarm(alarm.id);
                    },
                  ),
                  onTap: () {
                    // 수정 및 로직 테스트 (클릭 시 활성/비활성 토글)
                    // copyWith를 사용하여 상태 변경
                    final newStatus = !alarm.isEnabled;
                    alarmProvider.updateAlarm(
                      alarm.copyWith(isEnabled: newStatus),
                    );

                    if (newStatus) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("알람 켜짐 -> 콘솔 로그 확인하세요!")),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),

      // 3. 알람 추가 버튼 (Create 테스트)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 임의의 알람 데이터 생성
          final now = DateTime.now();
          final newAlarm = Alarm(
            id: now.toString(), // 유니크 ID
            hour: now.hour,
            minute: now.minute + 1, // 1분 뒤 알람
            label: "테스트 알람",
            isEnabled: true,
            weekdays: [], // 일회성 알람
            // weekdays: [1, 3, 5], // 월,수,금 반복 테스트하려면 주석 해제
          );

          alarmProvider.addAlarm(newAlarm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
