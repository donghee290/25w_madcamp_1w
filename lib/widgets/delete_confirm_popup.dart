import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'design_system_buttons.dart';

class DeleteConfirmPopup extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteConfirmPopup({
    super.key,
    required this.title,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6E6E7E), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 18,
                  fontFamily: 'HYkanM',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GrayButton(
                    label: "아니요",
                    onTap: onCancel,
                    width: 120, // Adjusted width
                    height: 45,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RedSubButton(
                    label: "정말이요!",
                    onTap: onConfirm,
                    width: 120, // Adjusted width
                    height: 45,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
