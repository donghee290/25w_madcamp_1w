import 'package:flutter/material.dart';
import 'first_alarm_step2_screen.dart';

class FirstAlarmStep1Screen extends StatelessWidget {
  const FirstAlarmStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FirstAlarmStep2Screen()),
            );
          },
          child: const Text('다음'),
        ),
      ),
    );
  }
}
