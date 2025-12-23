// [file name]: upload_page.dart
import 'package:flutter/material.dart';

class UploadPage extends StatelessWidget {
  final String title;
  const UploadPage({super.key, required this.title});

  void _pickFile() {
    // This is the placeholder for actual file picking logic
    // You would use a package like file_picker here.
    print("File picker dialog opened to select a file.");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current File Display
            Text(
              "Current File:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "my_resume.pdf", // Placeholder file name
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.green.shade400, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Upload Button
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.cloud_upload_outlined, size: 24),
              label: const Text("Select File to Upload (.pdf, .doc)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Note
            Center(
              child: Text(
                "Maximum file size: 5MB",
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}