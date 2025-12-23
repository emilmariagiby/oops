import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:app/data/supabase_service.dart';

// -------- THEME STATE -------- //
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(true);

void toggleTheme() {
  isDarkModeNotifier.value = !isDarkModeNotifier.value;
}

// -------- PAGE NAVIGATION -------- //
ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);

// -------- EMPLOYER JOB DATA -------- //
ValueNotifier<List<Map<String, dynamic>>> employerJobsNotifier = ValueNotifier([]);
ValueNotifier<List<Map<String, dynamic>>> postedJobsNotifier = ValueNotifier([]);

// -------- CANDIDATE DATA -------- //
ValueNotifier<List<Map<String, dynamic>>> swipedCandidatesNotifier =
    ValueNotifier<List<Map<String, dynamic>>>([]);

// -------- USER DATA (EMPLOYEE) -------- //
final ValueNotifier<String> userNameNotifier = ValueNotifier("User Name");
final ValueNotifier<String> userEmailNotifier = ValueNotifier("user@email.com");
final ValueNotifier<String> userRoleNotifier = ValueNotifier("Employee");

// -------- COMPANY DATA (EMPLOYER) -------- //
final ValueNotifier<String> employerCompanyNotifier = ValueNotifier("Tech Corp");
final ValueNotifier<String> companyNameNotifier = ValueNotifier("Company Name");
final ValueNotifier<String> companyEmailNotifier = ValueNotifier("company@email.com");
final ValueNotifier<String> companyDomainNotifier = ValueNotifier("Technology");
final ValueNotifier<String> companySizeNotifier = ValueNotifier("50+");
final ValueNotifier<String> companyPhoneNotifier = ValueNotifier("+1234567890");
final ValueNotifier<String> companyFoundedYearNotifier = ValueNotifier("2020");

// -------- DASHBOARD DATA -------- //
final ValueNotifier<int> totalApplicationsNotifier = ValueNotifier(0);
final ValueNotifier<int> successfulApplicationsNotifier = ValueNotifier(0);
final ValueNotifier<int> pendingApplicationsNotifier = ValueNotifier(0);
final ValueNotifier<int> failedApplicationsNotifier = ValueNotifier(0);

// -------- EMPLOYER DASHBOARD STATS -------- //
final ValueNotifier<int> totalJobsPostedNotifier = ValueNotifier(0);
final ValueNotifier<int> activeJobsNotifier = ValueNotifier(0);
final ValueNotifier<int> totalCandidatesNotifier = ValueNotifier(0);

// -------- AUTH STATE -------- //
final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

// -------- PROFILE NOTIFIER -------- //
final ValueNotifier<List<Map<String, dynamic>>> profilesNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

final _supabaseService = SupabaseService();

/// Call this once after Supabase.initialize() in main.dart
Future<void> initProfilesNotifier() async {
  try {
    final rows = await _supabaseService.fetchProfiles(limit: 100);
    profilesNotifier.value = rows;
    if (kDebugMode) debugPrint('initProfilesNotifier loaded ${rows.length} profiles');
  } catch (e) {
    if (kDebugMode) debugPrint('initProfilesNotifier error: $e');
  }
}
