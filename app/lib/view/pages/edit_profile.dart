// [file name]: edit_profile.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart'; // Assuming notifiers are used for state management

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController(text: userNameNotifier.value);
  final TextEditingController _emailController = TextEditingController(text: userEmailNotifier.value);
  final TextEditingController _dobController = TextEditingController(text: "01/01/1990");
  final TextEditingController _collegeController = TextEditingController(text: "Tech University");
  final TextEditingController _experienceController = TextEditingController(text: "5 Years");
  final TextEditingController _skillsController = TextEditingController(text: "Flutter, Dart, AWS");
  final TextEditingController _ctcController = TextEditingController(text: "10 LPA");
  
  // Local state for dropdown (Gender)
  String _selectedGender = "Male";
  final List<String> _genders = ["Male", "Female", "Other", "Prefer not to say"];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _collegeController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _ctcController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // 1. Update the Notifiers (or your actual state management solution)
    userNameNotifier.value = _nameController.text;
    userEmailNotifier.value = _emailController.text;
    // You would update the rest of the data here in a real app, 
    // likely by calling an API or database function.

    // 2. Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );

    // 3. Navigate back to the Account Page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "✏️ Edit Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Personal Details ---
            Text(
              "Personal Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Divider(),
            _buildTextField(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person,
              isDark: isDark,
            ),
            _buildTextField(
              controller: _emailController,
              label: "Email Address",
              icon: Icons.email,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _dobController,
              label: "Date of Birth (DD/MM/YYYY)",
              icon: Icons.cake,
              isDark: isDark,
            ),
            
            // Gender Dropdown
            _buildDropdownField(
              label: "Gender",
              icon: Icons.people_alt,
              value: _selectedGender,
              items: _genders,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              isDark: isDark,
            ),
            
            const SizedBox(height: 32),
            
            // --- Job-Related Details ---
            Text(
              "Job-Related Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Divider(),
            
            _buildTextField(
              controller: _experienceController,
              label: "Total Experience",
              icon: Icons.work,
              isDark: isDark,
              hint: "e.g., 5 Years",
            ),
            _buildTextField(
              controller: _skillsController,
              label: "Skills",
              icon: Icons.star,
              isDark: isDark,
              maxLines: 3,
              hint: "e.g., Flutter, Dart, AWS, SQL (Comma separated)",
            ),
            _buildTextField(
              controller: _ctcController,
              label: "Current CTC (Annual)",
              icon: Icons.attach_money,
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _collegeController,
              label: "College Name / Highest Education",
              icon: Icons.school,
              isDark: isDark,
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Text Fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        ),
      ),
    );
  }
  
  // Helper Widget for Dropdown Fields
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: isDark ? Colors.blue.shade200 : Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white54 : Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        ),
        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black54),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          );
        }).toList(),
      ),
    );
  }
}