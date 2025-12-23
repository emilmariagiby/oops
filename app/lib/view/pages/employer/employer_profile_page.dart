// [file name]: employer_profile_page.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/widgets/theme_toggle_widget.dart';
import 'package:app/data/supabase_service.dart';

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage> {
  final _svc = SupabaseService();
  bool _loading = false;
  Map<String, dynamic>? _lastRow;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _editField({
    required String title,
    required String initial,
    required String dbKey,
    required ValueNotifier<String> notifier,
  }) async {
    final controller = TextEditingController(text: initial);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (result != null) {
      final email = companyEmailNotifier.value;
      try {
        await _svc.updateEmployerFields(email: email, fields: {dbKey: result});
        // Re-fetch to reflect exactly what's in DB
        final row = await _svc.getEmployerByEmail(email);
        if (row != null) {
          companyNameNotifier.value = (row['company_name'] ?? '').toString();
          companyDomainNotifier.value = (row['domain'] ?? '').toString();
          companySizeNotifier.value = (row['company_size'] ?? '').toString();
          companyPhoneNotifier.value = (row['phone'] ?? '').toString();
        } else {
          notifier.value = result; // fallback
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $title updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Could not update $title: $e')));
        }
      }
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      var email = companyEmailNotifier.value.trim();
      if (email.isEmpty) {
        // fallback to userEmail if companyEmail not set
        email = userEmailNotifier.value.trim();
      }
      if (email.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No company email set. Set companyEmailNotifier.value first.')),
          );
        }
        return;
      }

      // Ensure UI shows the effective email used
      companyEmailNotifier.value = email;

      // Ensure login + employer rows exist (FK safety)
      await _svc.ensureLoginAndEmployer(email: email, userType: 'employer');

      Map<String, dynamic>? row = await _svc.getEmployerByEmail(email);
      if (row == null) {
        await _svc.upsertEmployer(email: email);
        row = await _svc.getEmployerByEmail(email);
      }

      if (row != null) {
        companyNameNotifier.value = (row['company_name'] ?? '').toString();
        companyDomainNotifier.value = (row['domain'] ?? '').toString();
        companySizeNotifier.value = (row['company_size'] ?? '').toString();
        companyPhoneNotifier.value = (row['phone'] ?? '').toString();
        _lastRow = Map<String, dynamic>.from(row);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load profile: $e');
      // Only show snackbar if not a network error
      if (mounted && !e.toString().contains('SocketException')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshFromDb() async {
    final email = companyEmailNotifier.value.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      final row = await _svc.getEmployerByEmail(email);
      if (row != null) {
        companyNameNotifier.value = (row['company_name'] ?? '').toString();
        companyDomainNotifier.value = (row['domain'] ?? '').toString();
        companySizeNotifier.value = (row['company_size'] ?? '').toString();
        companyPhoneNotifier.value = (row['phone'] ?? '').toString();
        _lastRow = Map<String, dynamic>.from(row);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editPhone(BuildContext context) async {
    final controller = TextEditingController(text: companyPhoneNotifier.value);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          title: const Text('Edit Phone'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Enter phone number'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
          ],
        );
      },
    );

    if (result != null) {
      final email = companyEmailNotifier.value;
      try {
        await _svc.updateEmployerPhone(email: email, phone: result);
        // Re-fetch to reflect exactly what's in DB
        final row = await _svc.getEmployerByEmail(email);
        if (row != null) {
          companyNameNotifier.value = (row['company_name'] ?? '').toString();
          companyDomainNotifier.value = (row['domain'] ?? '').toString();
          companySizeNotifier.value = (row['company_size'] ?? '').toString();
          companyPhoneNotifier.value = (row['phone'] ?? '').toString();
        } else {
          companyPhoneNotifier.value = result; // fallback
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Phone updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ Could not update phone: $e')));
        }
      }
    }
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
        actions: [
          IconButton(onPressed: _refreshFromDb, icon: const Icon(Icons.refresh)),
          const ThemeToggleWidget(),
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
              if (_loading)
                const LinearProgressIndicator(minHeight: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active email: ${companyEmailNotifier.value}', style: TextStyle(color: textColor.withOpacity(0.8))),
                    const SizedBox(height: 6),
                    if (_lastRow != null)
                      Text('Row: ${_lastRow}', style: TextStyle(color: textColor.withOpacity(0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Header
              Text(
                "🏢 Company Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 24),

              // Company Card - DYNAMIC DATA
              ValueListenableBuilder<String>(
                valueListenable: companyNameNotifier,
                builder: (context, companyName, child) {
                  return ValueListenableBuilder<String>(
                    valueListenable: companyEmailNotifier,
                    builder: (context, companyEmail, child) {
                      return ValueListenableBuilder<String>(
                        valueListenable: companyDomainNotifier,
                        builder: (context, companyDomain, child) {
                          return ValueListenableBuilder<String>(
                            valueListenable: companySizeNotifier,
                            builder: (context, companySize, child) {
                              return ValueListenableBuilder<String>(
                                valueListenable: companyPhoneNotifier,
                                builder: (context, companyPhone, child) {
                                  return Container(
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
                                    child: Row(
                                      children: [
                                        // Logo
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: highlight.withOpacity(0.1),
                                            border: Border.all(color: highlight.withOpacity(0.3)),
                                          ),
                                          child: Icon(
                                            Icons.business,
                                            size: 40,
                                            color: highlight.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Company Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () => _editField(title: 'Company Name', initial: companyName, dbKey: 'company_name', notifier: companyNameNotifier),
                                                child: Text(
                                                  companyName,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              GestureDetector(
                                                onTap: () => _editField(title: 'Domain', initial: companyDomain, dbKey: 'domain', notifier: companyDomainNotifier),
                                                child: Text(
                                                  "Domain: $companyDomain",
                                                  style: TextStyle(color: textColor.withOpacity(0.7)),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: () => _editField(title: 'Company Size', initial: companySize, dbKey: 'company_size', notifier: companySizeNotifier),
                                                child: Text(
                                                  "Company Size: $companySize",
                                                  style: TextStyle(color: textColor.withOpacity(0.7)),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Contact: $companyPhone",
                                                style: TextStyle(color: textColor.withOpacity(0.7)),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Contact Info Header
              Text(
                "📞 Contact Details",
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
                            _buildContactTile(Icons.phone, "Phone", companyPhone, isDark, textColor, onTap: () => _editPhone(context)),
                            Divider(color: highlight.withOpacity(0.2), height: 0),
                            _buildContactTile(Icons.email_outlined, "Email", companyEmail, isDark, textColor, isLast: true),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String value, bool isDark, Color textColor, {bool isLast = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.2)),
        ),
        child: Icon(icon, color: textColor.withOpacity(0.8), size: 20),
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
      onTap: onTap,
    );
  }
}