import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bullshit/theme/app_colors.dart';
import 'package:bullshit/services/permission_service.dart';


class PermissionSettingsPopupScreen extends StatelessWidget {
  const PermissionSettingsPopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PermissionSettingsPopupView();
  }
}

class _PermissionSettingsPopupView extends StatelessWidget {
  const _PermissionSettingsPopupView();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<PermissionService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.75)),
          ),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: AppColors.baseGray,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.baseWhite, width: 2),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: Color(0x66000000),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _highlightText(
                    text: '서비스 이용을 위해 필요한 권한을\n모두 허용해주세요.',
                    highlight: '권한',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '※ 권한을 허용하지 않으면 서비스를 이용할 수 없어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () => SystemNavigator.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGray,
                              foregroundColor: AppColors.baseBlack,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('나중에'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: service.isRequesting
                                ? null
                                : () async {
                                    final ok = await context
                                        .read<PermissionService>()
                                        .requestAllInOrder();
                                    if (!context.mounted) return;

                                    if (ok) {
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.baseYellow,
                              foregroundColor: AppColors.baseBlack,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('네!'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightText({required String text, required String highlight}) {
    final parts = text.split(highlight);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.baseWhite,
          fontSize: 16,
          height: 1.35,
        ),
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.baseRed),
          ),
          if (parts.length > 1) TextSpan(text: parts.sublist(1).join()),
        ],
      ),
    );
  }
}
