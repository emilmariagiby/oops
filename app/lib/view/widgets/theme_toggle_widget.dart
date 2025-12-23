// lib/view/widgets/theme_toggle_widget.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';


class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: ValueListenableBuilder<bool>(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDark, child) {
          return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
        },
      ),
      onPressed: () {
        toggleTheme();
      },
      tooltip: "Toggle Light/Dark Mode",
    );
  }
}
