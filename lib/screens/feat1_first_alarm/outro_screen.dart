import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bullshit/theme/app_colors.dart';
import '../main_screen.dart';

class OutroScreen extends StatelessWidget {
  const OutroScreen({super.key});

  Future<void> _finishFirstRun(BuildContext context) async {
    final box = Hive.box('appBox');
    await box.put('hasSeenIntro', true);

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseGray,
      body: SafeArea(
        child: Stack(
          children: [
            //1. illust-pepe
            Positioned(
              top: 90,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/illusts/illust-pepe.png',
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            //2. titleText
            Positioned(
              top: 420,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  '알람 생성 완료.\n이제부터는 변명 없다.\n기상은 우리가 담당한다.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'HYcysM',
                    fontSize: 22,
                    height: 1.45,
                  ),
                ),
              ),
            ),

            //3. Button
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 220,
                  height: 44,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _finishFirstRun(context),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: AppColors.secondaryGradient,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: const Center(
                          child: Text(
                            '서비스 이용하러 가기',
                            style: TextStyle(
                              fontFamily: 'HYkanB',
                              fontSize: 16,
                              color: AppColors.baseBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
