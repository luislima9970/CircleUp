import 'package:flutter/material.dart';

import '../screens/createcircle_screen.dart';
import '../screens/homepage_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/tasks_screen.dart';

class BottomNavbar extends StatelessWidget {

  final int currentIndex;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
  });

  void _onTap(
      BuildContext context,
      int index,
      ) {

    if (index == currentIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomepageScreen(),
        ),
      );
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CreateCircleScreen(),
        ),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TasksPageScreen(),
        ),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2A8CFF),
      unselectedItemColor: const Color(0xFF95A39A),
      showUnselectedLabels: true,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      currentIndex: currentIndex,
      onTap: (index) =>
          _onTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          label: 'Circles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_rtl),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}