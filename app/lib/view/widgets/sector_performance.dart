// [file name]: sector_performance.dart
import 'package:flutter/material.dart';
import 'package:app/constants/dummy_data.dart';

class SectorPerformance extends StatelessWidget {
  const SectorPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.green.withOpacity(0.2),
                  Colors.blue.withOpacity(0.2),
                ]
              : [
                  Colors.green.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
        ),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 SECTOR PERFORMANCE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Reduced from 18 to 16
              color: textColor,
              letterSpacing: 0.8, // Reduced from 1.0 to 0.8
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16 to 12
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8, // Reduced from 12 to 8
              mainAxisSpacing: 8, // Reduced from 12 to 8
              childAspectRatio: 3.2, // Increased from 3 to 3.2 (makes items less wide)
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final sector = DummyData.sectorPerformance[index];
              final isPositive = sector['change'] > 0;
              
              return Container(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10), // Reduced from 12 to 10
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      sector['icon'] as String,
                      style: const TextStyle(fontSize: 18), // Reduced from 20 to 18
                    ),
                    const SizedBox(width: 6), // Reduced from 8 to 6
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sector['sector'] as String,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11, // Reduced from 12 to 11
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2), // Added small spacing
                          Text(
                            '${isPositive ? '+' : ''}${sector['change']}%',
                            style: TextStyle(
                              color: isPositive ? Colors.green[700] : Colors.red[700],
                              fontSize: 12, // Reduced from 14 to 12
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}