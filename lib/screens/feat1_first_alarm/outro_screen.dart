import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main_screen.dart';

class OutroScreen extends StatelessWidget {
  const OutroScreen({super.key});

  Future<void> _finishFirstRun(BuildContext context) async {
    final box = Hive.box('appBox');
    await box.put('hasSeenIntro', true);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _finishFirstRun(context),
          child: const Text('시작하기'),
        ),
      ),
    );
  }
}
