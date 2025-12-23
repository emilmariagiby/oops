import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:app/constants/dummy_data.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/widgets/theme_toggle_widget.dart';
import 'package:app/data/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployerHomePage extends StatefulWidget {
  const EmployerHomePage({super.key});

  @override
  State<EmployerHomePage> createState() => _EmployerHomePageState();
}

class _EmployerHomePageState extends State<EmployerHomePage> {
  late final SwipableStackController _controller;
  final SupabaseService _svc = SupabaseService();

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
    _loadCandidates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeCompleted(int index, SwipeDirection direction) {
    final candidate = DummyData1.candidatesForSwiping[index];
    final applicationId = candidate['application_id'];
    final jobId = candidate['job_id'];
    final employeeEmail = candidate['email'];

    if (direction == SwipeDirection.right) {
      // Right swipe → schedule interview
      swipedCandidatesNotifier.value = [
        ...swipedCandidatesNotifier.value,
        {
          'candidate': candidate,
          'action': 'Interview Scheduled',
          'timestamp': DateTime.now(),
        }
      ];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Interview scheduled for ${candidate['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Persist interview + move application to 'interview' (non-blocking)
      if (jobId != null && employeeEmail != null && (employeeEmail as String).isNotEmpty) {
        // Create interview row in legacy 'interview' table
        _svc.createLegacyInterview(jobId: jobId as int, employeeEmail: employeeEmail as String);
      }
      if (applicationId != null) {
        _svc.updateApplicationStatus(applicationId: applicationId, status: 'interview');
      }
    } else {
      // Left swipe → rejected
      swipedCandidatesNotifier.value = [
        ...swipedCandidatesNotifier.value,
        {
          'candidate': candidate,
          'action': 'Rejected',
          'timestamp': DateTime.now(),
        }
      ];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Rejected ${candidate['name']}'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Optionally mark application as rejected
      if (applicationId != null) {
        _svc.updateApplicationStatus(applicationId: applicationId, status: 'rejected');
      }
    }
  }

  Future<void> _loadCandidates() async {
    try {
      // Use same email logic as other pages for consistency
      final authEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
      final employerEmail = authEmail.isNotEmpty
          ? authEmail
          : (companyEmailNotifier.value.isNotEmpty
              ? companyEmailNotifier.value
              : userEmailNotifier.value);
      
      debugPrint('🔍 Loading candidates for employer: $employerEmail');
      
      if (employerEmail.isEmpty) {
        debugPrint('⚠️ No employer email found');
        if (!mounted) return;
        setState(() {
          DummyData1.candidatesForSwiping = [];
        });
        return;
      }
      
      List<int> jobIds = await _svc.fetchEmployerJobIdsByEmail(employerEmail);
      debugPrint('✅ Found ${jobIds.length} jobs for employer');

      if (jobIds.isEmpty) {
        debugPrint('⚠️ No jobs posted yet - no candidates to show');
        if (!mounted) return;
        setState(() {
          DummyData1.candidatesForSwiping = [];
        });
        return;
      }

      final rows = await _svc.fetchEligibleCandidates(limit: 50, jobIds: jobIds);
      final mapped = rows.map<Map<String, dynamic>>((row) {
        final emp = (row['employee'] ?? {}) as Map;
        String s(Map m, String k) => (m[k] ?? '').toString();
        final name = s(emp, 'name');
        final email = s(emp, 'email');
        String role = s(emp, 'experience_level');
        int exp = 0;
        final match = RegExp(r'(\d+)').firstMatch(role);
        if (match != null) exp = int.tryParse(match.group(1)!) ?? 0;
        final rawSkills = emp['skills'];
        List<String> skills;
        if (rawSkills == null) skills = [];
        else if (rawSkills is List) skills = List<String>.from(rawSkills.map((e) => e.toString()));
        else skills = rawSkills.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        return {
          // keep existing UI keys
          'name': name.isNotEmpty ? name : 'Unnamed',
          'role': role.isNotEmpty ? role : '—',
          'experience': exp > 0 ? '$exp years' : '0 years',
          'skills': skills,
          'photo': 'https://via.placeholder.com/800x300.png?text=Profile',
          'email': email,
          'phone': '',
          // extra keys for backend actions
          'application_id': row['application_id'],
          'job_id': row['job_id'],
          'test_score': row['test_score'],
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        DummyData1.candidatesForSwiping = mapped;
      });
      debugPrint('✅ Loaded ${mapped.length} eligible candidates (test_score >= 80)');
    } catch (e) {
      debugPrint('⚠️ Error loading candidates: $e');
      // keep hardcoded data on error
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
