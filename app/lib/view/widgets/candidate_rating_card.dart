// lib/view/widgets/candidate_rating_card.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef PointsChanged = void Function(String name, double points);
typedef OnCardTap = void Function();

// helper to create Color from HSL (makes pastel choices easier)
Color hsl(double h, double s, double l) =>
    HSLColor.fromAHSL(1.0, h, s / 100.0, l / 100.0).toColor();

class CandidateRatingCard extends StatefulWidget {
  const CandidateRatingCard({
    super.key,
    required this.name,
    required this.role,
    required this.avatar,
    required this.points,
    required this.onPointsChanged,
    required this.onTap,
    this.rank,
  });

  final String name;
  final String role;
  final String avatar;
  final double points;
  final int? rank;
  final PointsChanged onPointsChanged;
  final OnCardTap onTap;

  @override
  State<CandidateRatingCard> createState() => _CandidateRatingCardState();
}

class _CandidateRatingCardState extends State<CandidateRatingCard> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _expanded = false;
  bool _hovering = false;

  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _shadow;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.points.toStringAsFixed(0));
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _shadow = Tween<double>(begin: 0.04, end: 0.18).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant CandidateRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) _controller.text = widget.points.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _setExpanded(bool v) {
    setState(() {
      _expanded = v;
      if (v) {
        _anim.forward();
      } else {
        _anim.reverse();
      }
    });
  }

  void _onIncrement() {
    final cur = double.tryParse(_controller.text) ?? 0.0;
    final next = (cur + 1).clamp(0, 100);
    _controller.text = next.toStringAsFixed(0);
    widget.onPointsChanged(widget.name, next.toDouble());
    _setExpanded(true);
  }

  void _onDecrement() {
    final cur = double.tryParse(_controller.text) ?? 0.0;
    final next = (cur - 1).clamp(0, 100);
    _controller.text = next.toStringAsFixed(0);
    widget.onPointsChanged(widget.name, next.toDouble());
    _setExpanded(true);
  }

  void _onTyped(String v) {
    var parsed = double.tryParse(v) ?? 0.0;
    if (parsed < 0) parsed = 0;
    if (parsed > 100) parsed = 100;
    final display = parsed.toStringAsFixed(0);
    if (_controller.text != display) {
      _controller.value = TextEditingValue(text: display, selection: TextSelection.collapsed(offset: display.length));
    }
    widget.onPointsChanged(widget.name, parsed.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopLike = kIsWeb ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.linux;

    // Palette tuned for a Lovable pastel look (adjust if you want exact hues)
    final pastelBlue = hsl(213, 70, 92); // light blue page accent
    final cardPink = theme.brightness == Brightness.dark ? Colors.white10 : hsl(340, 80, 98); // light pinkish card tone
    final primary = hsl(217, 91, 60); // accent blue

    Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar (bigger)
        CircleAvatar(
          radius: 28,
          backgroundColor: theme.brightness == Brightness.dark ? Colors.blueGrey.shade800 : pastelBlue,
          child: Text(widget.avatar, style: TextStyle(color: primary, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 16),
        // Name & role
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(widget.role, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
          ]),
        ),

        // Rating label + points input
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Rating Points', style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
            const SizedBox(height: 6),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 160),
              firstChild: _compactPointsBox(context),
              secondChild: _expandedControls(context),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            ),
          ],
        ),
      ],
    );

    Widget card = AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final scale = _scale.value;
        final shadow = _shadow.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: cardPink,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(shadow), blurRadius: 18 * shadow + 4, offset: Offset(0, 6 * shadow))],
            ),
            child: child,
          ),
        );
      },
      child: body,
    );

    Widget interactive = GestureDetector(
      onTap: () {
        _setExpanded(!_expanded);
        widget.onTap();
      },
      child: MouseRegion(
        onEnter: (_) {
          if (isDesktopLike) { setState(() => _hovering = true); _anim.forward(); }
        },
        onExit: (_) {
          if (isDesktopLike) { setState(() => _hovering = false); if (!_expanded) _anim.reverse(); }
        },
        child: card,
      ),
    );

    return interactive;
  }

  Widget _compactPointsBox(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Center(child: Text(_controller.text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
    );
  }

  Widget _expandedControls(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          SizedBox(width: 36, height: 36, child: IconButton(padding: EdgeInsets.zero, onPressed: _onDecrement, icon: const Icon(Icons.remove, size: 18))),
          Expanded(
            child: TextFormField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 6)),
              onChanged: _onTyped,
            ),
          ),
          SizedBox(width: 36, height: 36, child: IconButton(padding: EdgeInsets.zero, onPressed: _onIncrement, icon: const Icon(Icons.add, size: 18))),
        ],
      ),
    );
  }
}
