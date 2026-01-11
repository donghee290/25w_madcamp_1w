import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'providers/alarm_provider.dart';
import 'services/notification_service.dart';
import 'screens/alarm_result_screen.dart';
import 'screens/create_alarm_screen.dart'; // import creation screen
import 'screens/gallery_screen.dart';
import 'models/alarm_history.dart';
import 'providers/history_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // [Step 3 검증] Hive 초기화 및 설정
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // 어댑터 등록 (이 부분이 없으면 에러남)
  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(MissionTypeAdapter());
  Hive.registerAdapter(AlarmHistoryAdapter()); // History Adapter

  // 박스 열기
  await Hive.openBox<Alarm>('alarmBox');
  await Hive.openBox<AlarmHistory>('historyBox'); // History Box

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(),
        ), // HistoryProvider 추가
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }

  void _configureSelectNotificationSubject() {
    NotificationService().selectNotificationStream.stream.listen((
      String? payload,
    ) async {
      if (payload != null) {
        // Payload: id|duration|hour|minute
        final parts = payload.split('|');
        if (parts.length >= 4) {
          final int hour = int.parse(parts[2]);
          final int minute = int.parse(parts[3]);

          await navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AlarmResultScreen(
                scheduledHour: hour,
                scheduledMinute: minute,
                payload: payload,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const MainScreen(), // 메인 스크린 분리
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [TestScreen(), const GalleryScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: '알람'),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: '갤러리'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
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
                    "ID: ${alarm.id.substring(0, 5)}... / 요일: ${alarm.weekdays}\nSnooze: ${alarm.duration}분 간격",
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

      // 3. 알람 추가 버튼 (Create 화면 이동)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateAlarmScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
