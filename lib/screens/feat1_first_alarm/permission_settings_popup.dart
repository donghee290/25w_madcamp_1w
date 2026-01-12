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
          Positioned.fill(child: ColoredBox(color: AppColors.transparentBlack)),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(
                color: AppColors.baseGray,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.baseWhite, width: 2),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 3),
                    color: AppColors.transparentBlack,
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
                      fontFamily: 'HYkanM',
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
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => SystemNavigator.pop(),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: AppColors.gradWhite,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text(
                                    '나중에',
                                    style: TextStyle(
                                      fontFamily: 'HYkanM',
                                      fontSize: 14,
                                      color: AppColors.baseBlack,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: service.isRequesting
                                  ? null
                                  : () async {
                                      final ok = await context
                                          .read<PermissionService>()
                                          .requestAllInOrder();
                                      if (!context.mounted) return;
                                      if (ok) Navigator.of(context).pop(true);
                                    },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: AppColors.secondaryGradient,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: Text(
                                    '네!',
                                    style: TextStyle(
                                      fontFamily: 'HYkanB',
                                      fontSize: 14,
                                      color: AppColors.baseBlue,
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
          fontFamily: 'HYkanM',
          color: AppColors.baseWhite,
          fontSize: 16,
          height: 1.35,
        ),
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: highlight,
            style: const TextStyle(
              fontFamily: 'HYkanB',
              color: AppColors.baseRed,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.sublist(1).join()),
        ],
      ),
    );
  }
}
