import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/theme_toggle_widget.dart';
import '../../data/notifiers.dart';
import '../../data/supabase_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
      final email = authEmail.isNotEmpty
          ? authEmail
          : (companyEmailNotifier.value.isNotEmpty
              ? companyEmailNotifier.value
              : userEmailNotifier.value);

      if (email.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final jobs = await _svc.fetchEmployerJobs(employerEmail: email);
      _activeJobsCount = jobs.length;

      final jobIds = jobs.map((j) => j['job_id'] as int).toList();
      if (jobIds.isNotEmpty) {
        final applications = await _svc.fetchApplicationsForJobs(jobIds: jobIds);
        _applicationsCount = applications.length;
        _interviewsCount = applications.where((a) => a['status'] == 'interview').length;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('⚠️ Dashboard load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("JOBSWIPE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
                  'Welcome back, ${companyName.isEmpty ? 'TechCorp Inc.' : companyName}',
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
              const SizedBox(height: 25),

              // Stats cards
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _buildStatCard(_activeJobsCount.toString(), 'Active Jobs', Icons.work_outline_rounded, accentBlue, isDark),
                        _buildStatCard(_applicationsCount.toString(), 'Applications', Icons.description_outlined, accentBlue, isDark),
                        _buildStatCard(_interviewsCount.toString(), 'Interviews', Icons.calendar_today_rounded, accentBlue, isDark),
                        _buildStatCard('—', 'Hires Made', Icons.check_circle_rounded, accentBlue, isDark),
                        _buildStatCard(_applicationsCount > 0 ? '${((_interviewsCount / _applicationsCount) * 100).toStringAsFixed(0)}%' : '—', 'Response Rate', Icons.trending_up_rounded, accentBlue, isDark),
                      ],
                    ),

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

              const SizedBox(height: 30),
              Text(
                '⚡ Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),
              _buildActivityItem(
                'New Application',
                'Sarah Johnson applied for Senior Flutter Developer',
                '2 hours ago',
                Icons.person_outline,
                accentBlue,
                isDark,
              ),
              _buildActivityItem(
                'Interview Scheduled',
                'Michael Chen - UI/UX Designer - Tomorrow 10:00 AM',
                '5 hours ago',
                Icons.calendar_today_outlined,
                accentBlue,
                isDark,
              ),
              _buildActivityItem(
                'Job Posted',
                'Product Manager position posted',
                '1 day ago',
                Icons.work_outline,
                accentBlue,
                isDark,
              ),
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

  static Widget _buildAnalyticsSection(int applicationsCount, int interviewsCount, Color accentBlue, bool isDark) {
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
          _buildAnalyticsRow('Total Views', '—', '—', Icons.visibility_outlined, accentBlue, isDark),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          _buildAnalyticsRow('Applications', applicationsCount.toString(), '—', Icons.description_outlined, accentBlue, isDark),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          _buildAnalyticsRow('Response Rate', '$responseRate%', '—', Icons.trending_up, accentBlue, isDark),
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

  static Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color accentBlue,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentBlue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54, height: 1.3)),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }
}
