// lib/view/pages/candidate_evaluation_page.dart
import 'package:flutter/material.dart';
import '../../data/notifiers.dart'; // same path as original code
// used for consistent look (optional)
// if you want toggle here; otherwise remove

class CandidateEvaluationPage extends StatefulWidget {
  const CandidateEvaluationPage({
    super.key,
    required this.candidateEntryIndex,
    required this.candidateMap,
  });

  /// index into swipedCandidatesNotifier.value list so we can update in place
  final int candidateEntryIndex;
  final Map<String, dynamic> candidateMap; // the map that contains candidate (and nested candidate['candidate'])

  @override
  State<CandidateEvaluationPage> createState() => _CandidateEvaluationPageState();
}

class _CandidateEvaluationPageState extends State<CandidateEvaluationPage> {
  // controllers for six categories (0-10)
  final Map<String, TextEditingController> _catControllers = {};
  final TextEditingController _notesController = TextEditingController();

  final List<String> _cats = ['technical', 'experience', 'communication', 'cultureFit', 'problemSolving', 'attitude'];

  @override
  void initState() {
    super.initState();

    // If there are existing ratings, prefill them
    final existing = widget.candidateMap['candidate']['ratings'] as Map<String, dynamic>?;
    for (final c in _cats) {
      final start = existing != null && existing[c] != null ? (existing[c] as num).toString() : '';
      _catControllers[c] = TextEditingController(text: start);
    }

    _notesController.text = existing != null && existing['notes'] != null ? existing['notes'] as String : '';
  }

  @override
  void dispose() {
    for (var c in _catControllers.values) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  bool _allFilled() {
    for (final c in _cats) {
      final t = _catControllers[c]!.text.trim();
      if (t.isEmpty) return false;
      final parsed = double.tryParse(t);
      if (parsed == null) return false;
    }
    return true;
  }

  int _sumScoresInt() {
    var sum = 0.0;
    for (final c in _cats) {
      sum += double.tryParse(_catControllers[c]!.text) ?? 0.0;
    }
    return sum.round();
  }

  int _calculateFinalOutOf100() {
    final sum = _sumScoresInt(); // out of max 60
    final finalScore = ((sum / (10 * _cats.length)) * 100).round();
    return finalScore;
  }

  void _saveRatings() {
    if (!_allFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all 6 scores (0-10) before saving')));
      return;
    }

    final ratings = <String, dynamic>{};
    for (final c in _cats) {
      ratings[c] = double.parse(_catControllers[c]!.text).toDouble();
    }
    ratings['notes'] = _notesController.text.trim();
    final total = _calculateFinalOutOf100();
    ratings['total'] = total.toDouble();

    // write into swipedCandidatesNotifier in place at the provided index
    final list = [...swipedCandidatesNotifier.value];
    final entry = Map<String, dynamic>.from(list[widget.candidateEntryIndex]);
    final candidateObj = Map<String, dynamic>.from(entry['candidate'] as Map);
    candidateObj['ratings'] = ratings;
    candidateObj['points'] = total.toDouble(); // update points (keeps compatibility)
    entry['candidate'] = candidateObj;
    list[widget.candidateEntryIndex] = entry;
    swipedCandidatesNotifier.value = list; // notify listeners (U2)

    // show feedback and pop
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Ratings saved')));
    Navigator.of(context).pop(true); // return true to indicate saved (used by caller)
  }

  Widget _numberInput(String cat) {
    final ctrl = _catControllers[cat]!;
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              var cur = double.tryParse(ctrl.text) ?? 0.0;
              cur = (cur - 1).clamp(0, 10);
              ctrl.text = cur.toStringAsFixed(0);
              setState(() {});
            },
            icon: const Icon(Icons.remove, size: 18),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
            onChanged: (v) {
              var x = double.tryParse(v) ?? 0.0;
              if (x < 0) x = 0;
              if (x > 10) x = 10;
              ctrl.text = x.toStringAsFixed(0);
              ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
              setState(() {});
            },
          ),
        ),
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              var cur = double.tryParse(ctrl.text) ?? 0.0;
              cur = (cur + 1).clamp(0, 10);
              ctrl.text = cur.toStringAsFixed(0);
              setState(() {});
            },
            icon: const Icon(Icons.add, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(String title, String keyName, IconData icon) {
    final value = double.tryParse(_catControllers[keyName]!.text) ?? 0.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.04), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.02) : Colors.blue.withOpacity(0.06), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.blue[200] : Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('Score (0-10)', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))])),
          const SizedBox(width: 12),
          SizedBox(width: 150, child: _numberInput(keyName)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidate = widget.candidateMap['candidate'] as Map<String, dynamic>;
    final displayName = candidate['name'] ?? 'Unknown';
    final role = candidate['role'] ?? '';
    final avatar = candidate['avatar'] ?? (displayName.isNotEmpty ? displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join() : '');

    final curTotal = candidate['points'] != null ? (candidate['points'] as num).toInt() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluate Candidate'),
        actions: const [
          // if you want theme toggle here
          // ThemeToggleWidget(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header card with avatar + name + role + current score
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.04), blurRadius: 12, offset: const Offset(0, 6))]),
                child: Row(children: [
                  CircleAvatar(radius: 30, backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.blueGrey.shade800 : Colors.blue.withOpacity(0.08), child: Text(avatar, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(role, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('$curTotal/100', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const SizedBox(height: 4), Text('Current Score', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))])
                ]),
              ),
              const SizedBox(height: 18),

              // categories
              _categoryCard('Technical Skills', 'technical', Icons.code),
              _categoryCard('Experience', 'experience', Icons.work),
              _categoryCard('Communication', 'communication', Icons.chat_bubble_outline),
              _categoryCard('Culture Fit', 'cultureFit', Icons.people_alt_outlined),
              _categoryCard('Problem Solving', 'problemSolving', Icons.psychology_outlined),
              _categoryCard('Attitude', 'attitude', Icons.favorite_border),

              const SizedBox(height: 12),

              // Notes
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.04), blurRadius: 12, offset: const Offset(0, 6))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                  ),
                ]),
              ),

              const SizedBox(height: 20),

              // final score display + save button
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.blue.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Final Score', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 8),
                      Text('${_calculateFinalOutOf100()}/100', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _allFilled() ? _saveRatings : null,
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Save Rating')),
                  ),
                ),
              ]),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
