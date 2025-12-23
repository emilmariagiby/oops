import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/widgets/employer_navbar_widget.dart';

// Import all your pages
import 'package:app/view/pages/dashboard_page.dart';
import 'package:app/view/pages/employer/employer_home_page.dart';
import 'package:app/view/pages/employer/manage_jobs_page.dart';
import 'package:app/view/pages/rate_candidates_page.dart';
import 'package:app/view/pages/employer_profile_page.dart';

class EmployerWidgetTree extends StatelessWidget {
  const EmployerWidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,         // ✅ LISTEN to theme changes
      builder: (context, isDarkMode, _) {

        return ValueListenableBuilder<int>(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, child) {
            final List<Widget> employerPages = [
              const DashboardPage(),
              const EmployerHomePage(),
              const ManageJobsPage(),
              const RateCandidatesPage(),
              const EmployerProfilePage(),
            ];

            return Scaffold(
              body: employerPages.elementAt(selectedPage),
              bottomNavigationBar: const EmpNavbarWidget(),
            );
          },
        );

      },
    );
  }
}
