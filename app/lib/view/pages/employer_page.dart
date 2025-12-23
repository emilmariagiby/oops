// pages/employer_page.dart
import 'package:flutter/material.dart';
import '../widgets/application_widgets.dart';
import '../widgets/theme_toggle_widget.dart';
import '../widgets/market_section.dart';
import '../widgets/news_card_wide.dart';
import '../widgets/sector_performance.dart';

class EmployerPage extends StatefulWidget {
  const EmployerPage({super.key});

  @override
  State<EmployerPage> createState() => _EmployerPageState();
}

class _EmployerPageState extends State<EmployerPage> {
  int _selectedIndex = 0;
  String _selectedJobForApplications = 'Flutter Developer';
  String _candidateSearchQuery = '';
  String _selectedCandidateStatus = 'All';

  final List<Map<String, dynamic>> _postedJobs = [
    {
      'jobTitle': 'Flutter Developer',
      'company': 'TechCorp',
      'location': 'New York, NY',
      'salary': '\$80k - \$120k',
      'type': 'Full-time',
      'posted': '2 days ago',
    },
    {
      'jobTitle': 'Senior Designer',
      'company': 'DesignStudio',
      'location': 'San Francisco, CA',
      'salary': '\$90k - \$130k',
      'type': 'Full-time',
      'posted': '1 week ago',
    },
  ];

  final List<Map<String, dynamic>> _applications = [
    {
      'jobTitle': 'Flutter Developer',
      'candidates': [
        {
          'name': 'John Doe',
          'email': 'john@example.com',
          'location': 'New York, NY',
          'experience': '5 years',
          'appliedDate': '2 days ago',
          'status': 'Under Review',
          'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs'],
        },
        {
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'location': 'Boston, MA',
          'experience': '7 years',
          'appliedDate': '1 week ago',
          'status': 'Shortlisted',
          'skills': ['Flutter', 'Kotlin', 'CI/CD', 'Clean Code'],
        },
      ],
    },
    {
      'jobTitle': 'Senior Designer',
      'candidates': [
        {
          'name': 'Alex Johnson',
          'email': 'alex@example.com',
          'location': 'San Francisco, CA',
          'experience': '8 years',
          'appliedDate': '3 days ago',
          'status': 'Interview Scheduled',
          'skills': ['UI/UX', 'Figma', 'Prototyping', 'Design Systems'],
        },
      ],
    },
  ];

  final List<Map<String, String>> _newsData = [
    {
      'company': 'Tech News',
      'title': 'AI Revolution in Hiring: How Companies are Using AI',
      'imageUrl': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400',
      'readTime': '5 min',
      'views': '1.2k',
    },
    {
      'company': 'Business',
      'title': 'Remote Work Trends: The Future of Employment',
      'imageUrl': 'https://images.unsplash.com/photo-1664575602554-2087b04935a5?w=400',
      'readTime': '4 min',
      'views': '980',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'JobConnect Pro',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          ThemeToggleWidget(),
          SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 1 ? _buildFloatingActionButton() : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              label: 'Company',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showPostJobDialog,
      backgroundColor: const Color(0xFF2563EB),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Post Job', style: TextStyle(color: Colors.white)),
    );
  }

  void _showPostJobDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Post New Job',
          style: TextStyle(
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Job posting form will be implemented here.',
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab(isDark);
      case 1:
        return _buildJobsTab(isDark);
      case 2:
        return ApplicationWidgets.buildApplicationsTab(
          context,
          _applications,
          _selectedJobForApplications,
          _candidateSearchQuery,
          _selectedCandidateStatus,
          (value) => setState(() => _selectedJobForApplications = value),
          (value) => setState(() => _candidateSearchQuery = value),
          (value) => setState(() => _selectedCandidateStatus = value),
        );
      case 3:
        return _buildAnalyticsTab(isDark);
      case 4:
        return _buildCompanyTab(isDark);
      default:
        return _buildDashboardTab(isDark);
    }
  }

  Widget _buildDashboardTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          
          // Market Section
          const MarketSection(),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Jobs', '${_postedJobs.length}', Icons.work_outline, const Color(0xFF2563EB), isDark)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Applications', '3', Icons.people_outline, const Color(0xFF10B981), isDark)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildStatCard('Shortlisted', '2', Icons.star_outline, const Color(0xFFF59E0B), isDark)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard('Interviews', '1', Icons.calendar_today, const Color(0xFFEF4444), isDark)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Sector Performance
          const SectorPerformance(),
          const SizedBox(height: 20),
          
          // News Section
          Text(
            'Latest News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 15),
          ..._newsData.asMap().entries.map((entry) => NewsCardWide(
            news: entry.value,
            index: entry.key,
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Posted Jobs',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              ),
            ),
            Text(
              '${_postedJobs.length} jobs',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._postedJobs.map((job) => Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job['jobTitle'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job['type'],
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  const SizedBox(width: 5),
                  Text(
                    job['company'],
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Icon(Icons.location_on_outlined, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  const SizedBox(width: 5),
                  Text(
                    job['location'],
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job['salary'],
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Posted ${job['posted']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildAnalyticsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          const SectorPerformance(),
          const SizedBox(height: 20),
          const MarketSection(),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 80,
              color: Color(0xFF2563EB),
            ),
            const SizedBox(height: 20),
            Text(
              'Company Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Company settings and information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}