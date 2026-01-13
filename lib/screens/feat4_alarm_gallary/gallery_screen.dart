import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/gallery_detail_popup.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_history.dart';
import '../../providers/history_provider.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class GalleryItem {
  final String imagePath;
  final int score;
  final DateTime timestamp;

  GalleryItem({
    required this.imagePath,
    required this.score,
    required this.timestamp,
  });
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Dummy data removed. We now fetch from Provider.
  bool _isSortByScore = false; // Default: Latest (false)

  @override
  void initState() {
    super.initState();
    // No initialization of dummy data needed
  }

  List<GalleryItem> _getSortedItems(List<AlarmHistory> historyList) {
    // Convert History to Gallery Items (Filtering out ones without images if needed)
    final items = historyList
        .where((h) => h.imagePath.isNotEmpty)
        .map(
          (h) => GalleryItem(
            imagePath: h.imagePath,
            score: h.score,
            timestamp: h.timestamp,
          ),
        )
        .toList();

    if (_isSortByScore) {
      items.sort((a, b) {
        int scoreComp = b.score.compareTo(a.score);
        if (scoreComp != 0) return scoreComp;
        return b.timestamp.compareTo(a.timestamp);
      });
    } else {
      // Default Latest
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return items;
  }

  void _onSortPressed() {
    setState(() {
      _isSortByScore = !_isSortByScore;
    });
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Part 1: Top Bar (Gradient + Title)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                'MY 기상 갤러리',
                style: TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 32,
                  fontFamily: 'HYcysM',
                ),
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.black, thickness: 2, height: 2),
            ],
          ),
        ),
        // Part 2: Bottom Area (Body Color + Sort Button)
        Container(
          width: double.infinity,
          color: const Color(0xFF2E2E3E), // Match Body Color
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: BlackSubButton(
                label: _isSortByScore ? '점수순' : '최신순',
                width: 80,
                height: 32,
                onTap: _onSortPressed,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E3E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, provider, child) {
                  final items = _getSortedItems(provider.historyList);

                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        "아직 저장된 기상 기록이 없어요!",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 columns
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1.0, // Square
                        ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                GalleryDetailPopup(item: items[index]),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: AssetImage(items[index].imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
