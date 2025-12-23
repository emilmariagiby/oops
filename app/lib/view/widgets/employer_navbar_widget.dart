import 'package:flutter/material.dart';
import '../../data/notifiers.dart';

class EmpNavbarWidget extends StatelessWidget {
  const EmpNavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color selectedColor = Colors.blue;
    final Color unselectedColor = isDark ? Colors.white70 : Colors.black54;

    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedIndex, child) {
        return BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => selectedPageNotifier.value = index,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_rate),
              label: 'Rate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
