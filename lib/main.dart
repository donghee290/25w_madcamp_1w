import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'providers/alarm_provider.dart';
import 'services/notification_service.dart';
import 'screens/alarm_result_screen.dart';
import 'models/alarm_history.dart';
import 'providers/history_provider.dart';
import 'screens/main_screen.dart'; // Imported MainScreen

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(MissionTypeAdapter());
  Hive.registerAdapter(AlarmHistoryAdapter());

  await Hive.openBox<Alarm>('alarmBox');
  await Hive.openBox<AlarmHistory>('historyBox');

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2E2E3E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E2E3E),
          elevation: 0,
        ),
      ),
      home: const MainScreen(), // 메인 스크린 분리
    );
  }
}
