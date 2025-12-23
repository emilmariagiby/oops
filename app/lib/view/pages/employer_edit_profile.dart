// [file name]: employer_edit_profile.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/data/supabase_service.dart';

class EmployerEditProfilePage extends StatefulWidget {
  const EmployerEditProfilePage({super.key});

  @override
  State<EmployerEditProfilePage> createState() => _EmployerEditProfilePageState();
}

class _EmployerEditProfilePageState extends State<EmployerEditProfilePage> {
  // Controllers initialized with current notifier values
  final TextEditingController _nameController = TextEditingController(text: companyNameNotifier.value);
  final TextEditingController _emailController = TextEditingController(text: companyEmailNotifier.value);
  final TextEditingController _phoneController = TextEditingController(text: companyPhoneNotifier.value);
  final TextEditingController _domainController = TextEditingController(text: companyDomainNotifier.value);
  final TextEditingController _sizeController = TextEditingController(text: companySizeNotifier.value);
  final TextEditingController _locationController = TextEditingController(text: "San Francisco, CA"); // Placeholder for location
  final TextEditingController _aboutController = TextEditingController(text: "A leading tech company focused on developing AI solutions for job placement and recruitment."); // Placeholder for description
  final _svc = SupabaseService();
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _domainController.dispose();
    _sizeController.dispose();
    _locationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final email = companyEmailNotifier.value;
      try {
        await _svc.ensureLoginAndEmployer(email: email);
        await _svc.updateEmployerFields(email: email, fields: {
          'company_name': _nameController.text,
          'domain': _domainController.text,
          'company_size': _sizeController.text,
          'phone': _phoneController.text,
        });

        final row = await _svc.getEmployerByEmail(email);
        if (row != null) {
          companyNameNotifier.value = (row['company_name'] ?? '').toString();
          companyDomainNotifier.value = (row['domain'] ?? '').toString();
          companySizeNotifier.value = (row['company_size'] ?? '').toString();
          companyPhoneNotifier.value = (row['phone'] ?? '').toString();
        } else {
          companyNameNotifier.value = _nameController.text;
          companyDomainNotifier.value = _domainController.text;
          companySizeNotifier.value = _sizeController.text;
          companyPhoneNotifier.value = _phoneController.text;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company Profile Updated Successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save changes: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "⚙️ Edit Company Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- Company Details ---
              Text(
                "Basic Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const Divider(height: 16),
              
              _buildTextField(
                controller: _nameController,
                label: "Company Name",
                icon: Icons.business,
                isDark: isDark,
              ),
              _buildTextField(
                controller: _domainController,
                label: "Industry / Domain",
                icon: Icons.category,
                isDark: isDark,
              ),
              _buildTextField(
                controller: _sizeController,
                label: "Company Size (Employees)",
                icon: Icons.group,
                isDark: isDark,
              ),
              _buildTextField(
                controller: _locationController,
                label: "Headquarters Location",
                icon: Icons.location_city,
                isDark: isDark,
              ),
              
              const SizedBox(height: 24),
              
              // --- Contact Details ---
              Text(
                "Contact Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const Divider(height: 16),
              
              _buildTextField(
                controller: _emailController,
                label: "Official Email",
                icon: Icons.email,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              _buildTextField(
                controller: _phoneController,
                label: "Contact Phone",
                icon: Icons.phone,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 24),

              // --- About Us ---
              Text(
                "Company Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const Divider(height: 16),

              _buildTextField(
                controller: _aboutController,
                label: "About Us / Description",
                icon: Icons.description,
                isDark: isDark,
                maxLines: 5,
                hint: "Provide a brief description of your company...",
              ),

              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: primaryColor,
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
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
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
}