// [file name]: job_filters.dart
import 'package:flutter/material.dart';

class JobFiltersPage extends StatefulWidget {
  const JobFiltersPage({super.key});

  @override
  State<JobFiltersPage> createState() => _JobFiltersPageState();
}

class _JobFiltersPageState extends State<JobFiltersPage> {
  // Filter states
  double _minSalary = 3.0;
  double _maxSalary = 15.0;
  String _selectedExperience = 'Any';
  String _selectedLocation = 'Any';
  Set<String> _selectedJobTypes = {'Remote'};
  Set<String> _selectedJobFields = {'Tech'};
  Set<String> _selectedJobLevels = {'Entry Level'};
  bool _sponsorsH1B = false;

  // Dummy data for filters
  final List<String> _experienceLevels = ['Any', '0-1 years', '1-3 years', '3-5 years', '5+ years'];
  final List<String> _locations = ['Any', 'Remote', 'Bangalore', 'Mumbai', 'Delhi', 'Hyderabad', 'Chennai'];
  final List<String> _jobTypes = ['Remote', 'On-site', 'Hybrid', 'Part-time', 'Contract'];
  final List<String> _jobFields = ['Tech', 'Finance', 'Healthcare', 'Education', 'Marketing', 'Design'];
  final List<String> _jobLevels = ['Entry Level', 'Mid Level', 'Senior level'];

  void _applyFilters() {
    Navigator.pop(context, {
      'minSalary': _minSalary,
      'maxSalary': _maxSalary,
      'experience': _selectedExperience,
      'location': _selectedLocation,
      'jobTypes': _selectedJobTypes.toList(),
      'jobFields': _selectedJobFields.toList(),
      'jobLevels': _selectedJobLevels.toList(),
      'sponsorsH1B': _sponsorsH1B,
    });
  }

  void _resetFilters() {
    setState(() {
      _minSalary = 3.0;
      _maxSalary = 15.0;
      _selectedExperience = 'Any';
      _selectedLocation = 'Any';
      _selectedJobTypes = {'Remote'};
      _selectedJobFields = {'Tech'};
      _selectedJobLevels = {'Entry Level'};
      _sponsorsH1B = false;
    });
  }

  Widget _buildPillChip(String label, bool selected, VoidCallback onTap) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: selected 
              ? Colors.blue.withOpacity(0.9)
              : isDark 
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected 
                ? Colors.blue.shade700
                : isDark 
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer(Widget child) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildGlassContainer(
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔍 Edit Job Preferences',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Titles Section
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Titles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPillChip('Software Engineer', false, () {}),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.add, size: 18, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Add more job titles',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Locations Section
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Locations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildPillChip('Add Locations', false, () {}),
                              const SizedBox(height: 8),
                              Text(
                                'Add Locations to find jobs in specific areas (maximum 5)',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Divider(color: textColor.withOpacity(0.3)),
                      const SizedBox(height: 20),

                      // Premium Filters Section
                      Text(
                        'Premium Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Salary Range - Glassy Slider
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💰 Salary Range (LPA)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: RangeSlider(
                                  values: RangeValues(_minSalary, _maxSalary),
                                  min: 3.0,
                                  max: 30.0,
                                  divisions: 27,
                                  labels: RangeLabels(
                                    '₹${_minSalary.toStringAsFixed(1)}L',
                                    '₹${_maxSalary.toStringAsFixed(1)}L',
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      _minSalary = values.start;
                                      _maxSalary = values.end;
                                    });
                                  },
                                  activeColor: Colors.blue,
                                  inactiveColor: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${_minSalary.toStringAsFixed(1)} LPA',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '₹${_maxSalary.toStringAsFixed(1)} LPA',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Remote Options
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remote Options',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                children: _jobTypes.map((type) {
                                  final isSelected = _selectedJobTypes.contains(type);
                                  return _buildPillChip(type, isSelected, () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedJobTypes.remove(type);
                                      } else {
                                        _selectedJobTypes.add(type);
                                      }
                                    });
                                  });
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Job Types
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Types',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                children: ['Full Time', 'Internship', 'Contract', 'Part Time'].map((type) {
                                  final isSelected = _selectedJobTypes.contains(type);
                                  return _buildPillChip(type, isSelected, () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedJobTypes.remove(type);
                                      } else {
                                        _selectedJobTypes.add(type);
                                      }
                                    });
                                  });
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Job Levels
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Levels',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                children: _jobLevels.map((level) {
                                  final isSelected = _selectedJobLevels.contains(level);
                                  return _buildPillChip(level, isSelected, () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedJobLevels.remove(level);
                                      } else {
                                        _selectedJobLevels.add(level);
                                      }
                                    });
                                  });
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Job Requirements
                      _buildGlassContainer(
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Requirements',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _sponsorsH1B = !_sponsorsH1B;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _sponsorsH1B 
                                        ? Colors.blue.withOpacity(0.9)
                                        : isDark 
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: _sponsorsH1B 
                                          ? Colors.blue.shade700
                                          : isDark 
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _sponsorsH1B ? Icons.check_box : Icons.check_box_outline_blank,
                                        color: _sponsorsH1B ? Colors.white : textColor.withOpacity(0.6),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sponsors H1B',
                                        style: TextStyle(
                                          color: _sponsorsH1B ? Colors.white : textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
}