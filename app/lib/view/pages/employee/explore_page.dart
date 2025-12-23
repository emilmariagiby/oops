// [file name]: explore_page.dart
import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:app/constants/dummy_data.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/pages/employee/job_filters.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late SwipableStackController _controller;
  final List<Map<String, dynamic>> _swipedJobs = [];

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
    final job = DummyData.jobRolesForSwiping[index];
    final action = direction == SwipeDirection.right ? 'Applied' : 'Rejected';
    
    setState(() {
      _swipedJobs.add({
        'job': job,
        'action': action,
        'timestamp': DateTime.now(),
      });
    });

    if (direction == SwipeDirection.right) {
      totalApplicationsNotifier.value = totalApplicationsNotifier.value + 1;
      pendingApplicationsNotifier.value = pendingApplicationsNotifier.value + 1;
    }

    // Show snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          direction == SwipeDirection.right 
            ? '✅ Applied to ${job['title']} at ${job['company']}'
            : '❌ Rejected ${job['title']} at ${job['company']}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFilterPage() {
    // Navigate to your actual filter page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JobFiltersPage()), // Your actual filter page
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
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
          // Company Header with Logo
          Container(
            height: 180, // Reduced height for better phone proportions
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              image: DecorationImage(
                image: NetworkImage(job['logo']),
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
                    Colors.black.withOpacity(0.8), // Darker overlay for better text readability
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job['company'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12, // Slightly smaller
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Reduced from 24 for phone screens
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Job Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Salary
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey), // Smaller icon
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job['location'],
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 12, // Smaller font
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.attach_money, size: 14, color: Colors.green), // Smaller icon
                      const SizedBox(width: 4),
                      Text(
                        job['salary'],
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12, // Smaller font
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Job Type and Experience
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          job['type'],
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 11, // Smaller font
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          job['experience'],
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 11, // Smaller font
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 14, // Smaller font
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      job['description'],
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 12, // Smaller font
                        height: 1.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4, // Increased max lines
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Skills
                  Text(
                    'Required Skills',
                    style: TextStyle(
                      fontSize: 14, // Smaller font
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (job['skills'] as List<String>).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                color: isDark ? Colors.blue[300] : Colors.blue[700],
                                fontSize: 10, // Smaller font
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Posted and Applicants
                  Row(
                    children: [
                      Text(
                        '📅 ${job['posted']}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 10, // Smaller font
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '👥 ${job['applicants']} applicants',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 10, // Smaller font
                        ),
                      ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Filter Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '💼 Explore Jobs',
                    style: TextStyle(
                      fontSize: 20, // Smaller font for phone
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_swipedJobs.length} Applied',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12, // Smaller font
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button
                      IconButton(
                        onPressed: _showFilterPage,
                        icon: Icon(Icons.filter_list, color: textColor),
                        tooltip: 'Filter Jobs',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Swipeable Stack - Takes all remaining space
            Expanded(
              child: SwipableStack(
                controller: _controller,
                itemCount: DummyData.jobRolesForSwiping.length,
                onSwipeCompleted: _onSwipeCompleted,
                horizontalSwipeThreshold: 0.8,
                verticalSwipeThreshold: 0.8,
                builder: (context, properties) {
                  final index = properties.index;
                  final job = DummyData.jobRolesForSwiping[index];
                  
                  return _buildJobCard(job);
                },
              ),
            ),

            // Removed the bottom action buttons container completely
          ],
        ),
      ),
    );
  }
}