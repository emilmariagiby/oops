// [file name]: market_section.dart
import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';

class MarketSection extends StatefulWidget {
  const MarketSection({super.key});

  @override
  State<MarketSection> createState() => _MarketSectionState();
}

class _MarketSectionState extends State<MarketSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool showFirstSet = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blue.withOpacity(0.3),
                    Colors.purple.withOpacity(0.2),
                  ]
                : [
                    Colors.blue.withOpacity(0.15),
                    Colors.purple.withOpacity(0.08),
                  ],
          ),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📊 APPLICATION SUMMARY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (showFirstSet) ...[
              ValueListenableBuilder<int>(
                valueListenable: totalApplicationsNotifier,
                builder: (_, value, __) => _buildApplicationCard('Total Applications', value.toString(), Icons.work_outline, Colors.blue, isDark, textColor),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: successfulApplicationsNotifier,
                builder: (_, value, __) => _buildApplicationCard('Successful', value.toString(), Icons.check_circle_outline, Colors.green, isDark, textColor),
              ),
            ] else ...[
              ValueListenableBuilder<int>(
                valueListenable: pendingApplicationsNotifier,
                builder: (_, value, __) => _buildApplicationCard('Pending', value.toString(), Icons.pending_actions, Colors.orange, isDark, textColor),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<int>(
                valueListenable: failedApplicationsNotifier,
                builder: (_, value, __) => _buildApplicationCard('Failed', value.toString(), Icons.cancel_outlined, Colors.red, isDark, textColor),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildGlassToggle('Prev', true, isDark, textColor),
                  const SizedBox(width: 8),
                  _buildGlassToggle('Next', false, isDark, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(String title, String value, IconData icon, Color iconColor, bool isDark, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applications • Status',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassToggle(String label, bool isPrev, bool isDark, Color textColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isPrev) {
            showFirstSet = true;
          } else {
            showFirstSet = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: (isPrev && showFirstSet) || (!isPrev && !showFirstSet)
              ? LinearGradient(
                  colors: isDark
                      ? [Colors.blue.withOpacity(0.6), Colors.purple.withOpacity(0.4)]
                      : [Colors.blue.withOpacity(0.4), Colors.purple.withOpacity(0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: isDark 
                    ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
                    : [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}