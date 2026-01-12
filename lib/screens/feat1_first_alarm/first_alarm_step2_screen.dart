import 'package:flutter/material.dart';
import 'first_alarm_step3_screen.dart';

class FirstAlarmStep2Screen extends StatelessWidget {
  const FirstAlarmStep2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const FirstAlarmStep3Screen()),
            );
          },
          child: const Text('다음'),
        ),
      ),
    );
  }
}
