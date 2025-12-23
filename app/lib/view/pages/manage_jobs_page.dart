import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/theme_toggle_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/data/notifiers.dart';



class ManageJobsPage extends StatefulWidget {
  const ManageJobsPage({super.key});

  @override
  State<ManageJobsPage> createState() => _ManageJobsPageState();
}

class _ManageJobsPageState extends State<ManageJobsPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  Uint8List? _webImage;

  // Presets
  final List<String> _jobTitles = [
    "Frontend Developer", "Backend Developer", "Fullstack Developer", "Data Scientist",
    "Product Manager", "UI/UX Designer", "DevOps Engineer", "QA Engineer", "Mobile Developer", "Business Analyst",
  ];
  final List<String> _jobTypes = ["Full time", "Part time", "Internship", "Contract"];
  final List<String> _locations = ["Head Office - Dubai", "Branch - Abu Dhabi", "Branch - Sharjah"];
  final List<String> _quals = [
    "BTech CSE","BTech ECE","BTech IT","MTech CSE","MTech ECE",
    "MBA Finance","MBA Marketing","MBA HR","MSc CS","PhD CS",
    "MBBS","Other"
  ];
  final List<String> _skills = ["C","C++","Python","Java","AI","ML","Cloud","React","Node","SQL"];

  String? _companyName;
  String? _selectedTitle;
  String? _selectedType;
  String? _selectedLocation;
  String? _selectedQualification;
  Set<String> _selectedSkills = {};
  double _salaryLpa = 5;
  double _experience = 0;
  final TextEditingController _descController = TextEditingController();

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _companyName = employerCompanyNotifier.value;
    _selectedTitle = _jobTitles.first;
    _selectedType = _jobTypes.first;
    _selectedLocation = _locations.first;
    _selectedQualification = _quals.first;
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _animController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 800, imageQuality: 80);
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _pickedImage = File(picked.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not pick image.')));
    }
  }

  void _openPostJobSheet({Map<String, dynamic>? existingJob, int? index}) {
    if (existingJob != null) {
      _companyName = existingJob['company'] ?? employerCompanyNotifier.value;
      _selectedTitle = existingJob['title'] ?? _jobTitles.first;
      _selectedType = existingJob['type'] ?? _jobTypes.first;
      _selectedLocation = existingJob['location'] ?? _locations.first;
      _selectedQualification = existingJob['qualification'] ?? _quals.first;
      _salaryLpa = (existingJob['salaryLpa'] is num) ? (existingJob['salaryLpa'] as num).toDouble() : 5.0;
      _experience = (existingJob['experience'] is num) ? (existingJob['experience'] as num).toDouble() : 0.0;
      _selectedSkills = Set<String>.from(existingJob['skills'] ?? {});
      _descController.text = existingJob['description'] ?? '';
      if (kIsWeb) {
        _webImage = existingJob['webImage'];
      } else {
        _pickedImage = existingJob['imageFile'];
      }
    } else {
      _companyName = employerCompanyNotifier.value;
      _selectedTitle = _jobTitles.first;
      _selectedType = _jobTypes.first;
      _selectedLocation = _locations.first;
      _selectedQualification = _quals.first;
      _selectedSkills = {};
      _salaryLpa = 5;
      _experience = 0;
      _descController.clear();
      _pickedImage = null;
      _webImage = null;
    }

    _animController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FractionallySizedBox(heightFactor: 0.86, child: child!);
          },
          child: _buildSheetContent(existingJob: existingJob, index: index),
        ),
      ),
    ).whenComplete(() => _animController.reverse());
  }

  Widget _buildSheetContent({Map<String, dynamic>? existingJob, int? index}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBg = isDark ? Colors.black.withOpacity(0.9) : Colors.white;
    final Color labelColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20)],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 12),
              Text(existingJob == null ? '📝 Post a Job' : '✏️ Edit Job',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 12),

              // Image Upload
Text('Company / Job Image', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
const SizedBox(height: 6),
GestureDetector(
  onTap: _pickImageFromGallery,
  child: Container(
    height: 120,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.withOpacity(0.3)),
      color: Colors.blue.withOpacity(0.05),
    ),
    child: _webImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(_webImage!, fit: BoxFit.cover, width: double.infinity),
          )
        : (_pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity),
              )
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, color: Colors.blue, size: 30),
                    SizedBox(height: 6),
                    Text('Tap to upload image', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              )),
  ),
),
const SizedBox(height: 12),


              // Company
              Text('Company', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 20, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_companyName ?? employerCompanyNotifier.value, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Job Title
              Text('Job Title', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _buildDropdown(_jobTitles, _selectedTitle, (v) => setState(() => _selectedTitle = v)),
              const SizedBox(height: 12),

              // Qualification Dropdown
              Text('Qualification', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _buildDropdown(_quals, _selectedQualification, (v) => setState(() => _selectedQualification = v)),
              const SizedBox(height: 12),

              // Job Type & Location
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Job Type', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        _buildDropdown(_jobTypes, _selectedType, (v) => setState(() => _selectedType = v)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        _buildDropdown(_locations, _selectedLocation, (v) => setState(() => _selectedLocation = v)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Experience
              Text('Experience (years): ${_experience.toStringAsFixed(1)}', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              Slider(
                value: _experience,
                min: 0,
                max: 20,
                divisions: 40,
                label: '${_experience.toStringAsFixed(1)} yrs',
                onChanged: (v) => setState(() => _experience = v),
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Skills
              Text('Required Skills', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _skills.map((s) {
                  final selected = _selectedSkills.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: selected,
                    onSelected: (on) => setState(() {
                      if (on) {
                        _selectedSkills.add(s);
                      } else {
                        _selectedSkills.remove(s);
                      }
                    }),
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Salary
              Text('Salary (in LPA): ${_salaryLpa.toStringAsFixed(1)}', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              Slider(
                value: _salaryLpa,
                min: 0,
                max: 100,
                divisions: 200,
                label: '${_salaryLpa.toStringAsFixed(1)} LPA',
                onChanged: (v) => setState(() => _salaryLpa = v),
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Description
              Text('Job Description (~50 words)', style: TextStyle(color: labelColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                maxLength: 400,
                decoration: InputDecoration(
                  hintText: 'Write a short description (~50 words)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  final words = (val ?? '').trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
                  if (words.isEmpty) return 'Please provide description';
                  if (words.length > 120) return 'Keep description short (~50 words)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Submit
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? true) {
                          final job = {
                            'company': _companyName ?? employerCompanyNotifier.value,
                            'title': _selectedTitle,
                            'type': _selectedType,
                            'location': _selectedLocation,
                            'qualification': _selectedQualification,
                            'skills': _selectedSkills.toList(),
                            'salaryLpa': double.parse(_salaryLpa.toStringAsFixed(1)),
                            'experience': double.parse(_experience.toStringAsFixed(1)),
                            'description': _descController.text.trim(),
                            'imageFile': _pickedImage,
                            'webImage': _webImage,
                            'datePosted': DateTime.now().toIso8601String(),
                          };

                          final current = List<Map<String, dynamic>>.from(postedJobsNotifier.value);
                          if (existingJob == null) {
                            current.insert(0, job);
                          } else if (index != null) current[index] = job;

                          postedJobsNotifier.value = current;
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Job posted')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(existingJob == null ? 'Post Job' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, ValueChanged<String?> onChanged) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color containerColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(" JOBSWIPE"),
        actions: const [
          ThemeToggleWidget(),
        ],
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPostJobSheet(),
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  Colors.lightBlue.withOpacity(0.05),
                  Colors.blue.withOpacity(0.02),
                ]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('💼 Manage Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 6),
                      Text('Create, edit and manage your job postings', style: TextStyle(color: textColor.withOpacity(0.7))),
                    ]),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.filter_list),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Jobs List
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: postedJobsNotifier,
                  builder: (context, jobs, _) {
                    if (jobs.isEmpty) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 260),
                              alignment: Alignment.center,
                              child: Text(
                                'No job posted yet.\nTap "Post Job" to create one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textColor.withOpacity(0.6)),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: jobs.asMap().entries.map((entry) {
                        final i = entry.key;
                        final job = entry.value;
                        final skills = job['skills'] != null ? List<String>.from(job['skills']) : <String>[];
                        final experience = job['experience'] != null ? job['experience'].toStringAsFixed(1) : '0';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.withOpacity(0.08)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: (!kIsWeb && job['imageFile'] != null)
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(job['imageFile'] as File, width: 72, height: 72, fit: BoxFit.cover))
                                : (kIsWeb && job['webImage'] != null)
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(job['webImage'] as Uint8List, width: 72, height: 72, fit: BoxFit.cover))
                                    : Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.blue.withOpacity(0.06)),
                                        child: const Icon(Icons.work_outline, color: Colors.blue, size: 36),
                                      ),
                            title: Text(job['title'] ?? 'Untitled', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${job['location'] ?? 'Unknown'} • ₹${job['salaryLpa'] ?? 'N/A'} LPA', style: TextStyle(color: textColor.withOpacity(0.7))),
                                const SizedBox(height: 4),
                                Text('Experience: $experience yrs', style: TextStyle(color: textColor.withOpacity(0.7))),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: skills.map((s) => Chip(
                                    label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    backgroundColor: Colors.blue,
                                    visualDensity: VisualDensity.compact,
                                  )).toList(),
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  onPressed: () => _openPostJobSheet(existingJob: job, index: i),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    final current = List<Map<String, dynamic>>.from(postedJobsNotifier.value);
                                    current.removeAt(i);
                                    postedJobsNotifier.value = current;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}