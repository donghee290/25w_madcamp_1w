import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/alarm_model.dart';
import 'providers/alarm_provider.dart';
import 'providers/next_alarm_provider.dart';
import 'services/notification_service.dart';
import 'screens/alarm_trigger_screen.dart';
import 'models/alarm_history.dart';
import 'providers/history_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'screens/feat1_first_alarm/intro_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeDateFormatting('ko_KR', null);
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
    _checkNotificationLaunchDetails();
  }

  Future<void> _checkNotificationLaunchDetails() async {
    final notificationAppLaunchDetails = await NotificationService()
        .flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null) {
        _handlePayload(payload);
      }
    }
  }

  void _handlePayload(String payload) {
    final parts = payload.split('|');
    if (parts.length < 2) return;

    final alarmId = parts[1];

    final alarmBox = Hive.box<Alarm>('alarmBox');
    final Alarm? alarm = alarmBox.get(alarmId);

    if (alarm == null) {
      int hour = 0;
      int minute = 0;
      if (parts.length >= 4) {
        hour = int.tryParse(parts[2]) ?? 0;
        minute = int.tryParse(parts[3]) ?? 0;
      }

      final fallbackAlarm = Alarm(
        id: alarmId,
        label: '',
        hour: hour,
        minute: minute,
        payload: payload,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => AlarmTriggerScreen(alarm: fallbackAlarm),
          ),
        );
      });
      return;
    }

    alarm.payload = payload;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => AlarmTriggerScreen(alarm: alarm)),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    NotificationService().selectNotificationStream.stream.listen((
      String? payload,
    ) async {
      if (payload != null) {
        _handlePayload(payload);
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
