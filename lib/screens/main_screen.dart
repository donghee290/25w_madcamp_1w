import 'package:flutter/material.dart';
import 'feat3_alarm_list/alarm_list_screen.dart';
import 'feat4_alarm_gallary/gallery_screen.dart';
import 'feat2_creat_alarm/create_alarm_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AlarmListScreen(),
    const GalleryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNewAlarmPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateAlarmScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onAlarmListTap: () => _onItemTapped(0),
        onNewAlarmTap: _onNewAlarmPressed,
        onGalleryTap: () => _onItemTapped(1),
      ),
    );
  }
}
