import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import '../screens/feat4_alarm_gallary/gallery_screen.dart'; // To access GalleryItem
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';
import 'design_system_buttons.dart'; // Added import

class GalleryDetailPopup extends StatelessWidget {
  final GalleryItem item;
  final GlobalKey _globalKey = GlobalKey();

  GalleryDetailPopup({super.key, required this.item});

  String _getScoreFeedback(int score) {
    switch (score) {
      case 5:
        return "완벽\n해요!";
      case 4:
        return "잘했\n어요^^";
      case 3:
        return "괜찮\n아요~";
      case 2:
        return "분발\n하세욧!";
      case 1:
        return "최악\n..";
      default:
        return "기상\n완료!";
    }
  }

  String _getMissionAsset() {
    return "assets/illusts/illust-math.png"; // Placeholder
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        await Gal.putImageBytes(
          byteData.buffer.asUint8List(),
          name:
              "alarm_gallery_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}",
        );

        if (!context.mounted) return;
        _showSuccessPopup(context);
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (!context.mounted) return;

      String errorMsg = '오류가 발생했습니다.';
      if (e is GalException) {
        errorMsg = '저장 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Center(
          child: PopupSmall(
            height: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "갤러리에 저장되었습니다.",
                  style: TextStyle(
                    fontFamily: 'HYkanB',
                    fontSize: 18,
                    color: AppColors.baseWhite,
                  ),
                ),
                const SizedBox(height: 25),
                YellowMainButton(
                  label: "확인",
                  width: 100,
                  height: 40,
                  onTap: () {
                    Navigator.of(context).pop(); // Close success popup
                    Navigator.of(context).pop(); // Close detail popup
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        key: _globalKey,
        child: PopupBig(
          width: 350,
          height: 550,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header (X Button)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 15, 15, 5),
                    child: Icon(
                      Icons.close,
                      color: AppColors.baseWhite,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // Image section
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(item.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Info Section (UPDATED DESIGN)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Date, Time, Title
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${item.timestamp.year}년 ${item.timestamp.month}월 ${item.timestamp.day}일 (${_getWeekday(item.timestamp)})",
                              style: const TextStyle(
                                color: AppColors.baseWhite,
                                fontSize: 18,
                                fontFamily: 'HYkanM',
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: DateFormat(
                                      'hh:mm',
                                    ).format(item.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.baseWhite,
                                      fontSize: 36,
                                      fontFamily: 'HYcysM',
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: DateFormat(
                                      'a',
                                    ).format(item.timestamp),
                                    style: const TextStyle(
                                      color: AppColors.baseWhite,
                                      fontSize: 18,
                                      fontFamily: 'HYcysM',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.score >= 4 ? "최고의 컨디션!" : "조금 더 힘내봐요",
                              style: const TextStyle(
                                color: AppColors.baseWhite,
                                fontSize: 18,
                                fontFamily: 'HYkanM',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Right Column: Mission Icon + Score Text (UPDATED DESIGN)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _getMissionAsset(),
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getScoreFeedback(item.score),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: AppColors.baseYellow,
                                  fontSize: 20,
                                  fontFamily: 'HYkanB',
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Save Button (fontSize UPDATED to 16)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 25),
                  child: GestureDetector(
                    onTap: () => _saveToGallery(context),
                    child: const Text(
                      "내 갤러리에 저장하기",
                      style: TextStyle(
                        color: Color(0xFFD9D9D9),
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFD9D9D9),
                        fontFamily: 'HYkanM',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
