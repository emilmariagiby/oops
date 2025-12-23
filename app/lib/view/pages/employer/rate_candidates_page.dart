import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/widgets/theme_toggle_widget.dart';

class RateCandidatesPage extends StatefulWidget {
  const RateCandidatesPage({super.key});

  @override
  State<RateCandidatesPage> createState() => _RateCandidatesPageState();
}

class _RateCandidatesPageState extends State<RateCandidatesPage> {
  int topN = 10;
  final TextEditingController _topNController = TextEditingController(text: '10');

  // Candidates to display
  List<Map<String, dynamic>> candidatesToDisplay = [];

  // Controller for each candidate's points
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  void _loadCandidates() {
    candidatesToDisplay = swipedCandidatesNotifier.value
        .where((c) => c['action'] == 'Interview Scheduled')
        .map((c) {
      final candidate = Map<String, dynamic>.from(c['candidate']);
      candidate['points'] = candidate['points'] ?? 0.0;

      // Initialize controller
      _controllers[candidate['name']] =
          TextEditingController(text: (candidate['points'] as double).toStringAsFixed(0));
      return candidate;
    }).toList();
  }

  @override
  void dispose() {
    _topNController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _sortCandidates() {
    setState(() {
      candidatesToDisplay.sort(
          (a, b) => (b['points'] as double).compareTo(a['points'] as double));
    });
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
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.lightBlue.withOpacity(0.05), Colors.blue.withOpacity(0.02)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text('📊 Rate Candidates',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 20),

                // Top N input + Sort button
                Row(
                  children: [
                    const Text('Top N Candidates: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: _topNController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        onChanged: (val) {
                          setState(() {
                            topN = int.tryParse(val) ?? 10;
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: highlight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: highlight.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _sortCandidates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sort by Points'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Candidate list
                candidatesToDisplay.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text(
                            'No candidates to rate.\nEnsure interviews are scheduled.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor.withOpacity(0.6)),
                          ),
                        ),
                      )
                    : Column(
                        children: candidatesToDisplay.map((candidate) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: highlight.withOpacity(0.08)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8))
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(candidate['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                              subtitle: Text(candidate['role'] ?? '',
                                  style: TextStyle(color: textColor.withOpacity(0.7))),
                              trailing: SizedBox(
                                width: 70,
                                child: TextFormField(
                                  controller: _controllers[candidate['name']],
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    double points = double.tryParse(val) ?? 0;
                                    if (points < 0) points = 0;
                                    if (points > 100) points = 100;
                                    setState(() {
                                      candidate['points'] = points; // permanent
                                      _controllers[candidate['name']]!.text =
                                          points.toStringAsFixed(0);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Pts',
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    isDense: true,
                                    border:
                                        OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: highlight)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Take top N candidates based on points
                    final sorted = [...candidatesToDisplay]
                      ..sort((a, b) =>
                          (b['points'] as double).compareTo(a['points'] as double));
                    final accepted = sorted.take(topN).map((c) => c['name']).toList();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✅ Acceptance notifications sent to: ${accepted.join(', ')}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: highlight,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Send Acceptance Notifications', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
