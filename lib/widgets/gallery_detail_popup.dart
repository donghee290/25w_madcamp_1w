import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import '../screens/gallery_screen.dart'; // To access GalleryItem
import '../theme/app_colors.dart';
import 'design_system_layouts.dart';

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
        return "최악\n.."; // Adjusted for 2-char logic if possible
      default:
        return "기상\n완료!";
    }
  }

  // Temporary mapping for mission assets based on image paths or scores if random
  // Logic: For now, I'll use a placeholder mission asset or guess from generic logic
  String _getMissionAsset() {
    // In real app, GalleryItem should store missionType.
    // Placeholder: Return specific icon based on score or random
    return "assets/illusts/illust-math.png"; // Placeholder
  }

  Future<void> _saveToGallery(BuildContext context) async {
    // Capture
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
        // Use Gal to save
        await Gal.putImageBytes(
          byteData.buffer.asUint8List(),
          name:
              "alarm_gallery_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}",
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('갤러리에 저장되었습니다!')));
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

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the PopupBig in RepaintBoundary to capture it
    return Center(
      child: RepaintBoundary(
        key: _globalKey,
        child: PopupBig(
          width: 350, // Slightly wider for the layout
          height: 550, // Increased to prevent bottom overflow
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

              // Image
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.baseWhite, width: 2),
                  image: DecorationImage(
                    image: AssetImage(item.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Info Section (Row)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Date, Time, Title
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
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
                          // Time
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
                                    fontFamily: 'HYcysM', // Serif font
                                    letterSpacing: 2,
                                  ),
                                ),
                                TextSpan(
                                  text: DateFormat('a').format(item.timestamp),
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
                          // Title
                          Text(
                            "주말은 쉬는 날!!", // Placeholder or item.label
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

                    // Right Column: Mission Icon + Score Text
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                _getMissionAsset(),
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getScoreFeedback(item.score),
                                textAlign: TextAlign
                                    .left, // Left align looks better for 2 lines next to icon
                                style: const TextStyle(
                                  color: AppColors.baseYellow,
                                  fontSize: 20,
                                  fontFamily: 'HYkanB',
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Save Button (Bottom Right)
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
                        fontSize: 18,
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
