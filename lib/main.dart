import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'providers/alarm_provider.dart';
import 'providers/next_alarm_provider.dart';
import 'services/notification_service.dart';
import 'screens/alarm_result_screen.dart';
import 'models/alarm_history.dart';
import 'providers/history_provider.dart';
import 'screens/main_screen.dart';
import 'screens/feat1_first_alarm/intro_screen.dart';
import 'package:bullshit/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await NotificationService().init();

  Hive.registerAdapter(AlarmAdapter());
  Hive.registerAdapter(MissionTypeAdapter());
  Hive.registerAdapter(AlarmHistoryAdapter());

  await Hive.openBox<Alarm>('alarmBox');
  await Hive.openBox<AlarmHistory>('historyBox');
  await Hive.openBox('appBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),

        ChangeNotifierProxyProvider<AlarmProvider, NextAlarmProvider>(
          create: (_) => NextAlarmProvider(),
          update: (_, alarmProvider, nextProvider) {
            nextProvider ??= NextAlarmProvider();
            nextProvider.setAlarmProvider(alarmProvider);
            return nextProvider;
          },
        ),
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
      theme: AppTheme.dark,
      home: const _EntryGate(),
    );
  }
}

class _EntryGate extends StatefulWidget {
  const _EntryGate();

  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  late final bool _hasSeenIntro;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('appBox');
    _hasSeenIntro = box.get('hasSeenIntro', defaultValue: false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenIntro) return const MainScreen();
    return const IntroScreen();
  }
}
