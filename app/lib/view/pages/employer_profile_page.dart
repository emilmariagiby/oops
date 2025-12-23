// [file name]: employer_profile_page.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import '../widgets/theme_toggle_widget.dart';
import 'employer_edit_profile.dart'; 
import 'login_page.dart'; // <--- Ensure LoginPage is accessible or import it correctly

class EmployerProfilePage extends StatelessWidget {
  const EmployerProfilePage({super.key});
 
  // --- NEW LOGOUT DIALOG FUNCTION ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out of your company profile?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // 1. Reset Company Data (Crucial for a clean logout)
                companyNameNotifier.value = "Default Company Name";
                companyEmailNotifier.value = "default@company.com";
                companyPhoneNotifier.value = "N/A";
                companyDomainNotifier.value = "N/A";
                companySizeNotifier.value = "0";
                
                // Reset new fields (Assuming they are defined in notifiers.dart)
                // companyIndustryNotifier.value = "N/A";
                // companyWebsiteNotifier.value = "N/A";
                // companyFoundingYearNotifier.value = "N/A";

                Navigator.of(context).pop();
                
                // 2. Navigate back to the login page (or whichever page serves as the start)
                // NOTE: The 'login_page.dart' must be imported correctly relative to this file's location.
                // Assuming 'login_page.dart' is in the view/pages directory (if this file is in view/pages/employer)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false, // Clears the navigation stack
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    const Color highlight = Colors.blue;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "🏢 Company Profile",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),

              // --- Company Details Section ---
              Text(
                "📋 Company Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // Company Details Card
              _CompanyDetailsCard(isDark: isDark, textColor: textColor, cardColor: cardColor, highlight: highlight),
              
              const SizedBox(height: 32),

              // --- Contact Info Section ---
              Text(
                "📞 Contact Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // Contact Card - DYNAMIC DATA
              ValueListenableBuilder<String>(
                valueListenable: companyEmailNotifier,
                builder: (context, companyEmail, child) {
                  return ValueListenableBuilder<String>(
                    valueListenable: companyPhoneNotifier,
                    builder: (context, companyPhone, child) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: highlight.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildContactTile(Icons.phone, "Phone", companyPhone, isDark, textColor, highlight),
                            Divider(color: highlight.withOpacity(0.2), height: 0, indent: 16, endIndent: 16),
                            _buildContactTile(Icons.email_outlined, "Email", companyEmail, isDark, textColor, highlight, isLast: true),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // --- Settings Section ---
              Text(
                "⚙️ Account Settings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              
              // Settings Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: highlight.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context, 
                      Icons.edit_outlined, 
                      "Edit Company Profile", 
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EmployerEditProfilePage()),
                        );
                      }, 
                      isDark, 
                      textColor,
                      highlight
                    ),
                    Divider(color: highlight.withOpacity(0.2), height: 0, indent: 16, endIndent: 16),
                    // LOGOUT TILE: Calls the new _showLogoutDialog
                    _buildSettingsTile(
                      context, 
                      Icons.logout, 
                      "Logout", 
                      () {
                        _showLogoutDialog(context); // <--- CALLS LOGOUT DIALOG
                      }, 
                      isDark, 
                      textColor,
                      highlight,
                      isLast: true
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Contact tiles
  Widget _buildContactTile(IconData icon, String title, String value, bool isDark, Color textColor, Color highlight, {bool isLast = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: highlight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight.withOpacity(0.3)),
        ),
        child: Icon(icon, color: highlight, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor,
        ),
      ),
      onTap: () {},
    );
  }

  // Helper for Settings tiles
  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, VoidCallback onTap, bool isDark, Color textColor, Color highlight, {bool isLast = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: highlight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlight.withOpacity(0.3)),
        ),
        child: Icon(
          icon, 
          color: textColor.withOpacity(0.8),
          size: 20,
        ),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        )
      ),
      trailing: Icon(
        Icons.chevron_right, 
        color: textColor.withOpacity(0.6),
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

// --- Company Details Card (No changes here, but included for context) ---
class _CompanyDetailsCard extends StatelessWidget {
  const _CompanyDetailsCard({
    required this.isDark,
    required this.textColor,
    required this.cardColor,
    required this.highlight,
  });

  final bool isDark;
  final Color textColor;
  final Color cardColor;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    // We use a chain of ValueListenableBuilders to react to state changes
    return ValueListenableBuilder<String>(
      valueListenable: companyNameNotifier,
      builder: (_, companyName, __) => ValueListenableBuilder<String>(
        valueListenable: companyDomainNotifier,
        builder: (_, companyDomain, __) => ValueListenableBuilder<String>(
          valueListenable: companySizeNotifier,
          builder: (_, companySize, __) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: highlight.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Name
                Row(
                  children: [
                    // Logo/Image Placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: highlight.withOpacity(0.1),
                        border: Border.all(color: highlight.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 30,
                        color: highlight.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Company Name
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Details Grid
                Row(
                  children: [
                    Expanded(child: _buildDetailItem(Icons.category_outlined, "Domain", companyDomain, textColor)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDetailItem(Icons.group_outlined, "Size", companySize, textColor)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailItem(Icons.location_city_outlined, "HQ Location", "San Francisco, CA", textColor),
                const SizedBox(height: 16),
                _buildDetailItem(Icons.description_outlined, "About Us", "A leading tech company focused on developing AI solutions for job placement and recruitment.", textColor, isLongText: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value, Color textColor, {bool isLongText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: highlight.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLongText ? 14 : 16,
            color: textColor.withOpacity(isLongText ? 0.7 : 0.9),
            fontWeight: isLongText ? FontWeight.normal : FontWeight.w500,
          ),
          maxLines: isLongText ? 3 : 1,
          overflow: isLongText ? TextOverflow.ellipsis : TextOverflow.clip,
        ),
      ],
    );
  }
}