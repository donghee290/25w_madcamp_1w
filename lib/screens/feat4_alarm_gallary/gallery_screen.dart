import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/design_system_buttons.dart';
import '../../widgets/gallery_detail_popup.dart';

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
  // Dummy data with Score and Timestamp for sorting
  late List<GalleryItem> _items;
  bool _isSortByScore = false; // Default: Latest (false)

  @override
  void initState() {
    super.initState();
    _items = [
      GalleryItem(
        imagePath: 'assets/illusts/illust-pepe.png',
        score: 1,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-math.png',
        score: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-shake.png',
        score: 3,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-write.png',
        score: 5,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-colors.png',
        score: 2,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-sound.png',
        score: 4,
        timestamp: DateTime.now().subtract(const Duration(days: 0, hours: 5)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-record.png',
        score: 5,
        timestamp: DateTime.now(),
      ), // Just now
      GalleryItem(
        imagePath: 'assets/illusts/illust-gallery.png',
        score: 3,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-list.png',
        score: 1,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-alarm.png',
        score: 4,
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-alarm.png',
        score: 5,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      GalleryItem(
        imagePath: 'assets/illusts/illust-pepe.png',
        score: 2,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];
    _sortItems();
  }

  void _sortItems() {
    setState(() {
      if (_isSortByScore) {
        // Sort by Score (Desc) then Time (Desc)
        _items.sort((a, b) {
          int scoreComp = b.score.compareTo(a.score);
          if (scoreComp != 0) return scoreComp;
          return b.timestamp.compareTo(a.timestamp);
        });
      } else {
        // Sort by Time (Desc)
        _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    });
  }

  void _onSortPressed() {
    _isSortByScore = !_isSortByScore;
    _sortItems();
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
              const SizedBox(height: 20),
              const Text(
                'MY 기상 갤러리',
                style: TextStyle(
                  color: AppColors.baseWhite,
                  fontSize: 32,
                  fontFamily: 'HYcysM',
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.black,
                thickness: 2,
                height: 2,
              ),
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
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        builder: (context) => GalleryDetailPopup(item: _items[index]),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: const Color(0xFF2E2E3E),
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: AssetImage(_items[index].imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
