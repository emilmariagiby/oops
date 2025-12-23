import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';

class TopBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TopBarWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: Colors.blue,
              ),
              onPressed: () {
                isDarkModeNotifier.value = !isDarkModeNotifier.value;
              },
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
