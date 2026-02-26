import 'package:flutter/material.dart';
import '../../features/habits/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/habits/presentation/widgets/custom_fab.dart';
import '../../features/habits/presentation/pages/add_habit_page.dart';
import '../../features/tracking/presentation/pages/calendar_page.dart';
import '../../features/tracking/presentation/pages/stats_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    StatsPage(),
    ProfilePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddHabitPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      extendBody: true,
      floatingActionButton: CustomFAB(
        onPressed: _onAddHabit,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}