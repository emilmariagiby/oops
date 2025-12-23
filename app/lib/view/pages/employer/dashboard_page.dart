import 'package:flutter/material.dart';
import 'package:app/view/widgets/theme_toggle_widget.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/data/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SupabaseService _svc = SupabaseService();
  final Color accentBlue = Colors.blueAccent;
  
  int _activeJobsCount = 0;
  int _applicationsCount = 0;
  int _interviewsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Listen for job changes and refresh dashboard
    postedJobsNotifier.addListener(_onJobsChanged);
  }

  @override
  void dispose() {
    postedJobsNotifier.removeListener(_onJobsChanged);
    super.dispose();
  }

  void _onJobsChanged() {
    // Refresh dashboard when jobs are posted/edited/deleted
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      // Use same email logic as Manage Jobs page
      final authEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
      final email = authEmail.isNotEmpty
          ? authEmail
          : (companyEmailNotifier.value.isNotEmpty
              ? companyEmailNotifier.value
              : userEmailNotifier.value);
      
      debugPrint('🔍 Dashboard loading data for email: $email');
      
      if (email.isEmpty) {
        debugPrint('⚠️ Dashboard: No email found, setting counts to 0');
        if (mounted) {
          setState(() {
            _loading = false;
            _activeJobsCount = 0;
            _applicationsCount = 0;
            _interviewsCount = 0;
          });
        }
        return;
      }

      // Fetch jobs count and update the notifier so dashboard shows data
      final jobs = await _svc.fetchEmployerJobs(employerEmail: email);
      _activeJobsCount = jobs.length;
      
      // Update postedJobsNotifier so the dashboard displays the jobs
      postedJobsNotifier.value = jobs;
      
      debugPrint('✅ Dashboard: Found ${jobs.length} active jobs for email: $email');

      // Fetch applications count (for all employer's jobs)
      final jobIds = jobs.map((j) => j['job_id'] as int).toList();
      if (jobIds.isNotEmpty) {
        final applications = await _svc.fetchApplicationsForJobs(jobIds: jobIds);
        _applicationsCount = applications.length;

        // Count interviews
        _interviewsCount = applications.where((a) => a['status'] == 'interview').length;
      } else {
        _applicationsCount = 0;
        _interviewsCount = 0;
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('⚠️ Failed to load dashboard data: $e');
      if (mounted) {
        setState(() {
          _loading = false;
          _activeJobsCount = 0;
          _applicationsCount = 0;
          _interviewsCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(" JOBSWIPE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh dashboard',
          ),
          const ThemeToggleWidget(),
        ],
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ValueListenableBuilder<String>(
                valueListenable: companyNameNotifier,
                builder: (context, companyName, _) => Text(
                  'Welcome back, ${companyName.isEmpty ? 'Employer' : companyName}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your hiring dashboard overview',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              
              // Show email being used for data fetch
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Builder(
                  builder: (context) {
                    final authEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
                    final email = authEmail.isNotEmpty
                        ? authEmail
                        : (companyEmailNotifier.value.isNotEmpty
                            ? companyEmailNotifier.value
                            : userEmailNotifier.value);
                    return Text(
                      '📧 Employer: ${email.isEmpty ? 'Not set' : email}',
                      style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 25),

              // Loading indicator
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                // Stats cards - use ValueListenableBuilder to show live job count
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: postedJobsNotifier,
                  builder: (context, postedJobs, _) {
                    // Use posted jobs count directly from the notifier
                    final liveJobsCount = postedJobs.length;
                    debugPrint('📊 Dashboard showing: $liveJobsCount jobs from notifier, $_activeJobsCount from DB');
                    
                    return Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _buildStatCard(liveJobsCount.toString(), 'Active Jobs', Icons.work_outline_rounded, accentBlue, isDark),
                        _buildStatCard(_applicationsCount.toString(), 'Applications', Icons.description_outlined, accentBlue, isDark),
                        _buildStatCard(_interviewsCount.toString(), 'Interviews', Icons.calendar_today_rounded, accentBlue, isDark),
                        _buildStatCard('—', 'Hires Made', Icons.check_circle_rounded, accentBlue, isDark),
                        _buildStatCard('—', 'Response Rate', Icons.trending_up_rounded, accentBlue, isDark),
                      ],
                    );
                  },
                ),

              if (!_loading) ...[
                const SizedBox(height: 30),
                Text(
                  '📊 Analytics Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 15),
                _buildAnalyticsSection(_applicationsCount, _interviewsCount, accentBlue, isDark),
              ],

              if (!_loading) ...[
                const SizedBox(height: 30),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: postedJobsNotifier,
                  builder: (context, postedJobs, _) {
                    if (postedJobs.isEmpty) {
                      return Column(
                        children: [
                          Text(
                            '⚡ Get Started',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            ),
                            child: Text(
                              '💡 No active jobs yet! Go to "Manage Jobs" tab to post your first job. Once posted, it will appear in the "Active Jobs" count above.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStatCard(String value, String label, IconData icon, Color accentBlue, bool isDark) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentBlue, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(int applicationsCount, int interviewsCount, Color accentBlue, bool isDark) {
    final responseRate = applicationsCount > 0 
        ? ((interviewsCount / applicationsCount) * 100).toStringAsFixed(0) 
        : '0';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildAnalyticsRow('Total Applications', applicationsCount.toString(), '—', Icons.description_outlined, accentBlue, isDark),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          _buildAnalyticsRow('Moved to Interview', interviewsCount.toString(), '—', Icons.calendar_today_rounded, accentBlue, isDark),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          _buildAnalyticsRow('Interview Rate', '$responseRate%', '—', Icons.trending_up, accentBlue, isDark),
        ],
      ),
    );
  }

  static Widget _buildAnalyticsRow(
    String title,
    String value,
    String change,
    IconData icon,
    Color accentBlue,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, color: accentBlue),
        const SizedBox(width: 15),
        Expanded(
          child: Text(title,
              style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
        ),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 15)),
        const SizedBox(width: 10),
        Text(
          change,
          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
