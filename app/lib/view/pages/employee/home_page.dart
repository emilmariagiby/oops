// [file name]: home_page.dart
import 'package:flutter/material.dart';
import 'package:app/constants/dummy_data.dart';
import 'package:app/view/widgets/market_section.dart';
import 'package:app/view/widgets/news_card_wide.dart';
import 'package:app/view/widgets/sector_performance.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentNewsPage = 0;
  final int _newsPerPage = 4;

  List<Widget> _getCurrentNewsPage() {
    final startIndex = _currentNewsPage * _newsPerPage;
    final endIndex = startIndex + _newsPerPage;
    
    final List<Widget> newsWidgets = [];
    
    for (int i = startIndex; i < endIndex && i < DummyData.companyNews.length; i++) {
      newsWidgets.add(
        NewsCardWide(
          news: DummyData.companyNews[i],
          index: i,
        )
      );
    }
    
    return newsWidgets;
  }

  int get _totalNewsPages {
    return (DummyData.companyNews.length / _newsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDark, textColor),
                const SizedBox(height: 24),
                
                // STOCKS TODAY Section
                Text(
                  '📊 STOCKS TODAY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: textColor,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Live Market Section
                const MarketSection(),
                const SizedBox(height: 32),
                
                // MAJOR HEADLINES Section
                _buildNewsSection(isDark, textColor),
                const SizedBox(height: 24),
                
                // Sector Performance
                const SectorPerformance(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildHeader(bool isDark, Color textColor) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MarketInsights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Live Updates & Analysis',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
        ),
        child: Icon(Icons.notifications, color: textColor),
      ),
    ],
  );
}

  Widget _buildNewsSection(bool isDark, Color textColor) {
    final currentNews = _getCurrentNewsPage();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📰 MAJOR HEADLINES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: textColor,
                letterSpacing: 1.1,
              ),
            ),
            // Page Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
              ),
              child: Text(
                '${_currentNewsPage + 1}/$_totalNewsPages',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // News List
        ...currentNews,
        
        // Pagination Controls
        if (_totalNewsPages > 1) _buildPaginationControls(isDark, textColor),
      ],
    );
  }

  Widget _buildPaginationControls(bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          ElevatedButton(
            onPressed: _currentNewsPage > 0
                ? () {
                    setState(() {
                      _currentNewsPage--;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 14),
                SizedBox(width: 4),
                Text('Previous'),
              ],
            ),
          ),
          
          // Page Dots
          Row(
            children: List.generate(_totalNewsPages, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentNewsPage == index 
                      ? Colors.blue 
                      : textColor.withOpacity(0.3),
                ),
              );
            }),
          ),
          
          // Next Button
          ElevatedButton(
            onPressed: _currentNewsPage < _totalNewsPages - 1
                ? () {
                    setState(() {
                      _currentNewsPage++;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.2),
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              children: [
                Text('Next'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}