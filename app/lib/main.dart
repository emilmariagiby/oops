import 'package:flutter/material.dart';
import 'package:app/data/notifiers.dart';
import 'package:app/view/pages/login_page.dart';
import 'package:app/data/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://gxiuvdsdmllkfznppouu.supabase.co', // 🔑 your project URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4aXV2ZHNkbWxsa2Z6bnBwb3V1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MTU1NjAsImV4cCI6MjA3NjM5MTU2MH0.hGbEGli28k8iGCe1gvsNjbapTIvK0DSgpUp7GGRJOho',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _svc = SupabaseService();

  @override
  void initState() {
    super.initState();
    _bootstrapAuthBindings();
  }

  Future<void> _bootstrapAuthBindings() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? '';
      if (email.isNotEmpty) {
        companyEmailNotifier.value = email;
        userEmailNotifier.value = email;
        isLoggedInNotifier.value = true;
        // Ensure related rows exist for this employer
        try {
          await _svc.ensureLoginAndEmployer(email: email, userType: 'employer');
        } catch (e) {
          // Network error - continue anyway
          debugPrint('⚠️ Could not sync employer/login: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Bootstrap auth error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor:
                isDarkMode ? const Color(0xFF121212) : Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              foregroundColor: isDarkMode ? Colors.white : Colors.black,
              elevation: 1,
            ),
          ),
          home: const LoginPage(), // Start app on Login page
        );
      },
    );
  }
}
