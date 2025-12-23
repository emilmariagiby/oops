// [file name]: news_card_wide.dart
import 'package:flutter/material.dart';

class NewsCardWide extends StatelessWidget {
  final Map<String, String> news;
  final int index;
  
  const NewsCardWide({super.key, required this.news, required this.index});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      height: 220, // Increased from 180 to 220 (taller)
      margin: const EdgeInsets.only(bottom: 24), // Increased from 16 to 24 (more space between boxes)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              news['imageUrl']!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0), // Increased from 16 to 20 for more internal spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Slightly larger padding
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    news['company']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Increased from 8 to 12
                Text(
                  news['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Slightly larger font
                    fontWeight: FontWeight.bold,
                    height: 1.4, // Increased line height
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12), // Increased from 8 to 12
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Slightly larger
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '📅 Mar ${15 + index}',
                        style: const TextStyle(
                          fontSize: 11, // Slightly larger
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Increased from 12 to 16
                    Icon(Icons.schedule, size: 14, color: Colors.white.withOpacity(0.9)), // Slightly larger icon
                    const SizedBox(width: 6), // Increased from 4 to 6
                    Text(
                      news['readTime']!,
                      style: const TextStyle(
                        fontSize: 12, // Slightly larger
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16), // Increased from 12 to 16
                    Icon(Icons.visibility, size: 14, color: Colors.white.withOpacity(0.9)), // Slightly larger icon
                    const SizedBox(width: 6), // Increased from 4 to 6
                    Text(
                      news['views']!,
                      style: const TextStyle(
                        fontSize: 12, // Slightly larger
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}