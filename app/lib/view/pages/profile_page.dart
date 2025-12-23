// [file name]: profile_page.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'login_page.dart';
import 'edit_profile.dart'; 
import 'upload_page.dart'; // <--- NEW IMPORT for CV/Resume Upload
 
class AccountPage extends StatelessWidget {
  const AccountPage({super.key}); 

  // Function to handle profile image tap (placeholder for opening gallery)
  void _editProfilePhoto(BuildContext context) {
    // In a real app, this would open an Image Picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Photo Edit feature triggered! (Opens Gallery)')),
    );
    // You would typically use a package like image_picker here.
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color containerColor = isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9);
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.transparent : Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withOpacity(0.05),
                    Colors.purple.withOpacity(0.02),
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "👤 My Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                
                // --- Profile Section (User Name/Email) ---
                ValueListenableBuilder<String>(
                  valueListenable: userNameNotifier,
                  builder: (context, userName, child) {
                    return ValueListenableBuilder<String>(
                      valueListenable: userEmailNotifier,
                      builder: (context, userEmail, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Profile Photo (Now clickable)
                              InkWell( // <--- Made the image clickable
                                onTap: () => _editProfilePhoto(context),
                                borderRadius: BorderRadius.circular(40),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person, 
                                    size: 40, 
                                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.blue.withOpacity(0.7)
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        "Premium Member",
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // --- Personal Information Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "📝 Personal & Job Info",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: textColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                _PersonalInformationSection(
                  isDark: isDark,
                  textColor: textColor,
                  containerColor: containerColor,
                ),
                
                const SizedBox(height: 32),
                
                // --- Settings Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "⚙️ Settings",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: textColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Settings Cards Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      buildSettingsTile(Icons.edit_outlined, "Edit Profile", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      }, isDark, textColor),
                      const Divider(height: 0, indent: 16, endIndent: 16),
                      buildSettingsTile(Icons.notifications_outlined, "Notifications", () {}, isDark, textColor),
                      buildSettingsTile(Icons.logout, "Logout", () {
                        _showLogoutDialog(context);
                      }, isDark, textColor, isLast: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Settings tiles
  Widget buildSettingsTile(IconData icon, String title, VoidCallback onTap, bool isDark, Color textColor, {bool isLast = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
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
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
        ),
        child: Icon(
          Icons.chevron_right, 
          color: textColor.withOpacity(0.6),
          size: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  // Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Reset user data
                userNameNotifier.value = "User Name";
                userEmailNotifier.value = "user@email.com";
                userRoleNotifier.value = "Employee";
                
                Navigator.of(context).pop();
                // Navigate back to login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

// --- Updated Widget for Personal Information ---
class _PersonalInformationSection extends StatelessWidget {
  const _PersonalInformationSection({
    required this.isDark,
    required this.textColor,
    required this.containerColor,
  });

  final bool isDark;
  final Color textColor;
  final Color containerColor;

  // Function to handle CV upload navigation
  void _navigateToCVUpload(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UploadPage(title: "Upload CV/Resume")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Personal Info
          _buildInfoTile(Icons.cake_outlined, "Date of Birth", "01/01/1990", isDark, textColor),
          const Divider(height: 0, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.people_alt_outlined, "Gender", "Male", isDark, textColor), 
          const Divider(height: 0, indent: 16, endIndent: 16),
          
          // Job-Related Info
          _buildInfoTile(Icons.work_outline, "Experience", "5 Years", isDark, textColor), 
          const Divider(height: 0, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.star_outline, "Skills", "Flutter, Dart, AWS", isDark, textColor), 
          const Divider(height: 0, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.attach_money, "Current CTC", "10 LPA", isDark, textColor),
          const Divider(height: 0, indent: 16, endIndent: 16),
          _buildInfoTile(Icons.school_outlined, "College Name", "Tech University", isDark, textColor),
          const Divider(height: 0, indent: 16, endIndent: 16),
          _buildCVUploadTile(context, isDark, textColor, isLast: true), // <-- Pass context
        ],
      ),
    );
  }

  // Helper for CV Upload tile (Updated to use navigation)
  Widget _buildCVUploadTile(BuildContext context, bool isDark, Color textColor, {bool isLast = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Icon(Icons.upload_file, color: Colors.red, size: 20),
      ),
      title: Text(
        "Upload CV/Resume", 
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        )
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "my_resume.pdf", 
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.chevron_right, 
              color: textColor.withOpacity(0.6),
              size: 16,
            ),
          ),
        ],
      ),
      onTap: () => _navigateToCVUpload(context), // <--- Navigation added here
    );
  }

  // Helper for general information tiles (no change)
  Widget _buildInfoTile(IconData icon, String title, String value, bool isDark, Color textColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.green, size: 20),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
        )
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 16,
          color: textColor.withOpacity(0.8),
        ),
      ),
      onTap: () {
        // Tapping these fields could navigate to EditProfilePage or a specific modal.
        print("$title tapped");
      }, 
    );
  }
}