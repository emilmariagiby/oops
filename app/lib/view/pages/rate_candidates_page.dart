// lib/view/pages/rate_candidates_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/notifiers.dart';
import '../widgets/candidate_rating_card.dart';
import '../widgets/theme_toggle_widget.dart';
import 'candidate_evaluation_page.dart';

// small HSL helper to produce pastel colors
Color hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1.0, h, s / 100.0, l / 100.0).toColor();

class RateCandidatesPage extends StatefulWidget {
  const RateCandidatesPage({super.key});
  @override
  State<RateCandidatesPage> createState() => _RateCandidatesPageState();
}

class _RateCandidatesPageState extends State<RateCandidatesPage> {
  int topN = 10;
  final TextEditingController _topNController = TextEditingController(text: '10');
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> candidatesToDisplay = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadCandidatesFromNotifier();
    swipedCandidatesNotifier.addListener(_onSwipedListChanged);
  }

  void _onSwipedListChanged() => _loadCandidatesFromNotifier();

  void _loadCandidatesFromNotifier() {
    final source = swipedCandidatesNotifier.value;
    candidatesToDisplay = source.where((c) => c['action'] == 'Interview Scheduled').map((c) {
      final candidate = Map<String, dynamic>.from(c['candidate'] as Map);
      candidate['points'] = (candidate['points'] as num?)?.toDouble() ?? 0.0;
      _controllers.putIfAbsent(candidate['name'], () => TextEditingController(text: (candidate['points'] as double).toStringAsFixed(0)));
      return candidate;
    }).toList();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _topNController.dispose();
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    swipedCandidatesNotifier.removeListener(_onSwipedListChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _sortCandidates() {
    setState(() {
      candidatesToDisplay.sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorted successfully — Candidates sorted by rating points')));
  }

  void _onPointsChange(String name, double points) {
    final idx = candidatesToDisplay.indexWhere((c) => c['name'] == name);
    if (idx != -1) {
      setState(() {
        candidatesToDisplay[idx]['points'] = points;
        final ctrl = _controllers[name];
        if (ctrl != null && ctrl.text != points.toStringAsFixed(0)) {
          ctrl.value = TextEditingValue(text: points.toStringAsFixed(0), selection: TextSelection.collapsed(offset: points.toStringAsFixed(0).length));
        }
      });
      final list = [...swipedCandidatesNotifier.value];
      final entryIndex = list.indexWhere((entry) {
        final candidate = entry['candidate'] as Map;
        return candidate['name'] == name;
      });
      if (entryIndex != -1) {
        final entry = Map<String, dynamic>.from(list[entryIndex]);
        final candidateObj = Map<String, dynamic>.from(entry['candidate'] as Map);
        candidateObj['points'] = points;
        entry['candidate'] = candidateObj;
        list[entryIndex] = entry;
        swipedCandidatesNotifier.value = list;
      }
    }
  }

  Future<void> _openEvaluation(int entryIndex, Map<String, dynamic> originalEntry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CandidateEvaluationPage(candidateEntryIndex: entryIndex, candidateMap: originalEntry)),
    );

    if (result == true) {
      final name = originalEntry['candidate']['name'] as String;
      final newIdx = candidatesToDisplay.indexWhere((c) => c['name'] == name);
      if (newIdx != -1) {
        const cardHeightEstimate = 120.0;
        final targetOffset = (newIdx * cardHeightEstimate).clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 420), curve: Curves.easeOut);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Rating saved and updated')));
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = hsl(217, 91, 60);
    final pageBg = isDark ? null : LinearGradient(colors: [hsl(206, 88, 96), hsl(217, 91, 98)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final Color textColor = isDark ? Colors.white : Colors.black;
    // Button color that adapts nicely in light/dark
    final Color btnColor = isDark ? Colors.blue.shade400 : Colors.blue;
    final ButtonStyle pillStyle = ElevatedButton.styleFrom(
      backgroundColor: btnColor,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 6,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(" JOBSWIPE"),
        actions: const [
          ThemeToggleWidget(),
        ],
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: pageBg),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  // header card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.28 : 0.04), blurRadius: 12, offset: const Offset(0, 6))]),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📊 Rate Candidates', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('Evaluate and rank your top candidates', style: theme.textTheme.bodySmall)])),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black.withOpacity(0.03))),
                          child: Column(children: [Icon(Icons.person, color: primary), const SizedBox(height: 6), Text('${candidatesToDisplay.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const Text('Total Candidates')]),
                        ),
                      ]),
                    ),
                  ),

                  // controls row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.22 : 0.02), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Row(
                        children: [
                          const Text('Top Candidates:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 74,
                            child: TextFormField(
                              controller: _topNController,
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => topN = int.tryParse(val) ?? 10),
                              decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                          const Spacer(),

                          // SORT button styled like ManageJobsPage
                         ElevatedButton.icon(
  onPressed: _sortCandidates,
  icon: const Icon(Icons.sort, color: Colors.white),
  label: const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Text(
      'Sort by Points',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // consistent blue tone
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // more rounded corners
    ),
    elevation: 5,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    shadowColor: Colors.black.withOpacity(0.15),
  ),
),


                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // candidates list (scrollable)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: candidatesToDisplay.isEmpty
                          ? Center(child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_off, size: 48, color: theme.textTheme.bodySmall?.color), const SizedBox(height: 12), const Text('No candidates to rate.\nEnsure interviews are scheduled.', textAlign: TextAlign.center)])))
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: candidatesToDisplay.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, i) {
                                final c = candidatesToDisplay[i];
                                return CandidateRatingCard(
                                  name: c['name'],
                                  role: c['role'] ?? '',
                                  avatar: c['avatar'] ?? (c['name'] as String).split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                                  points: (c['points'] as num?)?.toDouble() ?? 0.0,
                                  rank: null,
                                  onPointsChanged: _onPointsChange,
                                  onTap: () {
                                    final list = swipedCandidatesNotifier.value;
                                    final entryIndex = list.indexWhere((entry) {
                                      final candidate = entry['candidate'] as Map;
                                      return candidate['name'] == c['name'];
                                    });
                                    if (entryIndex != -1) {
                                      _openEvaluation(entryIndex, list[entryIndex]);
                                    } else {
                                      _openEvaluation(i, {'candidate': c, 'action': 'Interview Scheduled'});
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ),

                  // bottom CTA area: left info, right big rounded button (responsive)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 520;
                      if (narrow) {
                        // vertical stacked layout for narrow screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Container(
                            //   padding: const EdgeInsets.all(12),
                            //   decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
                            //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            //     Text('Ready to send notifications?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            //     const SizedBox(height: 6),
                            //     Text('Top $topN candidates will receive acceptance emails', style: theme.textTheme.bodySmall),
                            //   ]),
                            // ),
                            const SizedBox(height: 12),

                            ElevatedButton.icon(
  onPressed: () {
    final sorted = [...candidatesToDisplay]
      ..sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));
    final accepted = sorted.take(topN).map((c) => c['name']).toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Acceptance notifications sent to: ${accepted.join(", ")}',
        ),
      ),
    );
  },
  icon: const Icon(Icons.send, color: Colors.white),
  label: const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Text(
      'Send Acceptance Notifications',
      style: TextStyle(
        color: Colors.white, // White text
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Blue background like ManageJobsPage
    foregroundColor: Colors.white, // Ensures icons/text stay white
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shadowColor: Colors.black.withOpacity(0.15),
  ),
),

                          ],
                        );
                      } else {
                        // wide layout: left info + right pill button
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Ready to send notifications?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text('Top $topN candidates will receive acceptance emails', style: theme.textTheme.bodySmall),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Notify button (wide) - pill style that matches ManageJobsPage look
                            SizedBox(
                              width: 260,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final sorted = [...candidatesToDisplay]..sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));
                                  final accepted = sorted.take(topN).map((c) => c['name']).toList();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Acceptance notifications sent to: ${accepted.join(", ")}')));
                                },
                                icon: const Icon(Icons.send),
                                label: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Send Acceptance Notifications')),
                                style: pillStyle,
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
