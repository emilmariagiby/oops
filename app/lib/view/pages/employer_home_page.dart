import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:app/constants/dummy_data.dart';
import '../widgets/theme_toggle_widget.dart';
import '../../data/notifiers.dart';
import '../../data/application_state.dart';

class EmployerHomePage extends StatefulWidget {
  const EmployerHomePage({super.key});

  @override
  State<EmployerHomePage> createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends State<EmployerHomePage> {
  late final SwipableStackController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeCompleted(int index, SwipeDirection direction) {
    final candidate = DummyData1.candidatesForSwiping[index];

    if (direction == SwipeDirection.right) {
      // Right swipe → schedule interview and update application status
      swipedCandidatesNotifier.value = [
        ...swipedCandidatesNotifier.value,
        {
          'candidate': candidate,
          'action': 'Interview Scheduled',
          'timestamp': DateTime.now(),
        }
      ];

      // Update application status counts
      ApplicationState.recordEmployerDecision(true);
      successfulApplicationsNotifier.value = successfulApplicationsNotifier.value + 1;
      pendingApplicationsNotifier.value = pendingApplicationsNotifier.value - 1;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Interview scheduled for ${candidate['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );

      // TODO: Trigger backend/email API
    } else {
      // Left swipe → rejected and update application status
      swipedCandidatesNotifier.value = [
        ...swipedCandidatesNotifier.value,
        {
          'candidate': candidate,
          'action': 'Rejected',
          'timestamp': DateTime.now(),
        }
      ];

      // Update application status counts
      ApplicationState.recordEmployerDecision(false);
      failedApplicationsNotifier.value = failedApplicationsNotifier.value + 1;
      pendingApplicationsNotifier.value = pendingApplicationsNotifier.value - 1;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Rejected ${candidate['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: DecorationImage(
                image: NetworkImage(candidate['photo']),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(candidate['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(candidate['role'],
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),

          // Candidate Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Experience: ${candidate['experience']}',
                      style: TextStyle(color: textColor, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('Skills:',
                      style: TextStyle(
                          color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (candidate['skills'] as List<String>).map((skill) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(skill,
                            style: TextStyle(
                                color: isDark ? Colors.blue[300] : Colors.blue[700],
                                fontSize: 12)),
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text('📧 ${candidate['email']}',
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 12)),
                      const Spacer(),
                      Text('📞 ${candidate['phone']}',
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(" JOBSWIPE"),
        actions: const [
          ThemeToggleWidget(),
        ],
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('👥 Explore Candidates',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: swipedCandidatesNotifier,
                    builder: (context, swipedList, _) {
                      final rightSwipeCount = swipedList
                          .where((c) => c['action'] == 'Interview Scheduled')
                          .length;
                      return Text('$rightSwipeCount Swiped',
                          style: TextStyle(
                              color: textColor.withOpacity(0.7), fontSize: 12));
                    },
                  ),
                ],
              ),
            ),

            // Swipable Stack
            Expanded(
              child: SwipableStack(
                controller: _controller,
                itemCount: DummyData1.candidatesForSwiping.length,
                onSwipeCompleted: _onSwipeCompleted,
                horizontalSwipeThreshold: 0.8,
                verticalSwipeThreshold: 0.8,
                builder: (context, properties) {
                  final index = properties.index;
                  final candidate = DummyData1.candidatesForSwiping[index];
                  return _buildCandidateCard(candidate);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: swipedCandidatesNotifier,
        builder: (context, swipedList, _) {
          final rightSwipeCount = swipedList
              .where((c) => c['action'] == 'Interview Scheduled')
              .length;

          return rightSwipeCount > 0
              ? FloatingActionButton.extended(
                  onPressed: () => selectedPageNotifier.value = 3,
                  label: Text(
                      'Rate $rightSwipeCount candidate${rightSwipeCount > 1 ? 's' : ''} →'),
                  icon: const Icon(Icons.star_rate),
                  backgroundColor: Colors.blue,
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
} 
