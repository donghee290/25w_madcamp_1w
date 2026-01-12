import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppStartProvider extends ChangeNotifier {
  bool _initialized = false;
  bool _hasSeenIntro = false;

  bool get initialized => _initialized;
  bool get hasSeenIntro => _hasSeenIntro;

  Future<void> init() async {
    final box = await Hive.openBox('app');
    _hasSeenIntro = box.get('hasSeenIntro', defaultValue: false) as bool;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setHasSeenIntro() async {
    final box = await Hive.openBox('app');
    await box.put('hasSeenIntro', true);
    _hasSeenIntro = true;
    notifyListeners();
  }
}
