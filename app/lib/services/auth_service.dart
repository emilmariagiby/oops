import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign up a new user
  /// Returns a map with user data and user_type
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userType, // 'employee' or 'employer'
    String? companyName, // Optional, used for employer signup
  }) async {
    try {
      // Step 1: Create user in Supabase Auth
      final AuthResponse authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userEmail = authResponse.user!.email!;

      // Step 2: Insert into login table
      await _supabase.from('login').insert({
        'email': userEmail,
        'full_name': fullName,
        'user_type': userType.toLowerCase(), // Ensure lowercase for constraint
      });

      // Step 3: Insert into employee or employer table based on user_type
      if (userType.toLowerCase() == 'employee') {
        await _supabase.from('employee').insert({
          'email': userEmail,
          'name': fullName,
        });
      } else if (userType.toLowerCase() == 'employer') {
        await _supabase.from('employer').insert({
          'email': userEmail,
          'company_name': companyName ?? fullName, // Use companyName if provided, else fullName
        });
      } else {
        throw Exception('Invalid user type. Must be "employee" or "employer"');
      }

      // Step 4: Fetch the created user data
      return await signIn(email: email, password: password);
    } on PostgrestException catch (e) {
      // Handle database errors
      if (e.code == '23505') {
        // Unique violation (duplicate email)
        throw Exception('This email is already registered.');
      } else if (e.code == '23503') {
        // Foreign key violation
        throw Exception('Database error: Invalid reference.');
      } else {
        throw Exception('Database error: ${e.message}');
      }
    } on AuthException catch (e) {
      // Handle Supabase Auth errors
      if (e.message.contains('already registered') || e.message.contains('User already registered')) {
        throw Exception('This email is already registered.');
      }
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw Exception('This email is already registered.');
      }
      throw Exception('An error occurred during sign up: ${e.toString()}');
    }
  }

  /// Sign in an existing user
  /// Returns a map with user data and user_type
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Authenticate with Supabase Auth
      final AuthResponse authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Invalid email or password.');
      }

      final userEmail = authResponse.user!.email!;

      // Step 2: Fetch from login table to get user_type and full_name
      final loginData = await _supabase
          .from('login')
          .select()
          .eq('email', userEmail)
          .single();

      final userType = loginData['user_type'] as String? ?? 'employee';
      final fullName = loginData['full_name'] as String? ?? 'User';

      // Step 3: Fetch from employee or employer table based on user_type
      Map<String, dynamic> userData = {
        'email': userEmail,
        'full_name': fullName,
        'user_type': userType,
      };

      if (userType.toLowerCase() == 'employee') {
        final employeeData = await _supabase
            .from('employee')
            .select()
            .eq('email', userEmail)
            .maybeSingle();

        if (employeeData != null) {
          userData.addAll(employeeData);
        }
      } else if (userType.toLowerCase() == 'employer') {
        final employerData = await _supabase
            .from('employer')
            .select()
            .eq('email', userEmail)
            .maybeSingle();

        if (employerData != null) {
          userData.addAll(employerData);
        }
      }

      return userData;
    } on AuthException catch (e) {
      // Handle authentication errors
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('Invalid email or password')) {
        throw Exception('Invalid email or password.');
      }
      throw Exception('Authentication error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      if (e.toString().contains('Invalid') || e.toString().contains('password')) {
        throw Exception('Invalid email or password.');
      }
      throw Exception('An error occurred during sign in: ${e.toString()}');
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('An error occurred during sign out: ${e.toString()}');
    }
  }

  /// Get the currently authenticated user
  /// Returns null if no user is signed in
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final userEmail = user.email!;

      // Fetch from login table
      final loginData = await _supabase
          .from('login')
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (loginData == null) {
        return null;
      }

      final userType = loginData['user_type'] as String? ?? 'employee';
      final fullName = loginData['full_name'] as String? ?? 'User';

      Map<String, dynamic> userData = {
        'email': userEmail,
        'full_name': fullName,
        'user_type': userType,
      };

      // Fetch role-specific data
      if (userType.toLowerCase() == 'employee') {
        final employeeData = await _supabase
            .from('employee')
            .select()
            .eq('email', userEmail)
            .maybeSingle();

        if (employeeData != null) {
          userData.addAll(employeeData);
        }
      } else if (userType.toLowerCase() == 'employer') {
        final employerData = await _supabase
            .from('employer')
            .select()
            .eq('email', userEmail)
            .maybeSingle();

        if (employerData != null) {
          userData.addAll(employerData);
        }
      }

      return userData;
    } catch (e) {
      return null;
    }
  }
}

