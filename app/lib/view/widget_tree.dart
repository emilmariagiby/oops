import 'package:app/data/notifiers.dart';
import 'package:app/view/pages/explore_page.dart';
import 'package:app/view/pages/home_page.dart';
import 'package:app/view/pages/profile_page.dart';
import 'package:app/view/pages/test_page.dart';
import 'package:flutter/material.dart';
import '../view/widgets/navbar_widget.dart';

List<Widget>pages=[
  const HomePage(),
  const ExplorePage(),
  const TestPage(),
  const AccountPage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Mapp'),
          centerTitle: true,
          actions: [
              IconButton(
                onPressed: () {
                  isDarkModeNotifier.value = !isDarkModeNotifier.value;
                },
                icon: ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder:  (context, isDarkMode, child) {
                    return Icon(isDarkMode ? Icons.dark_mode:Icons.light_mode);
                  },
                ),
              ),
          ],
        ),
        body: ValueListenableBuilder(valueListenable: selectedPageNotifier, 
        builder: (context, selectedPage, child) {
            return pages.elementAt(selectedPage);
          },
        ),
        bottomNavigationBar: const NavbarWidget()
      );
  }
}