import 'package:flutter/material.dart';
import 'outro_screen.dart';

class FirstAlarmStep3Screen extends StatelessWidget {
  const FirstAlarmStep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OutroScreen()),
            );
          },
          child: const Text('다음'),
        ),
      ),
    );
  }
}
