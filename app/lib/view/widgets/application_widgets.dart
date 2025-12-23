// lib/widgets/application_widgets.dart
import 'package:flutter/material.dart';

class ApplicationWidgets {
  // This is a placeholder for the buildApplicationsTab used in EmployerPage
  static Widget buildApplicationsTab(
    BuildContext context,
    List<Map<String, dynamic>> applications,
    String selectedJob,
    String searchQuery,
    String selectedStatus,
    ValueChanged<String> onJobChange,
    ValueChanged<String> onSearchChange,
    ValueChanged<String> onStatusChange,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Applications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        ...applications.map((jobApp) {
          final candidates = jobApp['candidates'] as List<dynamic>;
          return Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ExpansionTile(
              title: Text(
                jobApp['jobTitle'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text('${candidates.length} candidates'),
              children: candidates.map((candidate) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(candidate['name']),
                  subtitle: Text(
                    '${candidate['experience']} • ${candidate['status']}',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
