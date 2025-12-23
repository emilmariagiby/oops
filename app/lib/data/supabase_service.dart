import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProfiles({int limit = 50}) async {
    final data = await _client
        .from('profiles')
        .select('*')
        .limit(limit);
    final list = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return list;
  }

  Future<int?> getEmployerIdByEmail(String email) async {
    // Not applicable: employer table uses 'email' as primary key in current schema
    return null;
  }

  Future<List<int>> fetchEmployerJobIds(int employerId) async {
    // Not applicable: job_posting is keyed by employer_email in current schema
    return <int>[];
  }

  Future<List<Map<String, dynamic>>> fetchEligibleCandidates({
    int limit = 50,
    String? employerEmail,
    List<dynamic>? jobIds, // optional scoping to employer jobs
  }) async {
    var q = _client
        .from('job_application')
        .select(
          'application_id, job_id, test_score, status, applied_date, '
          'employee:employee_email ( name, email, skills, experience_level )',
        );
    if (jobIds != null && jobIds.isNotEmpty) {
      q = q.inFilter('job_id', jobIds);
    }
    final data = await q
        .gte('test_score', 80)
        .order('applied_date', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> createInterviewForApplication({
    required dynamic applicationId, // supports uuid or int based on schema
    DateTime? scheduledAt,
    String status = 'scheduled',
    String? notes,
  }) async {
    final payload = {
      'application_id': applicationId,
      'scheduled_at': (scheduledAt ?? DateTime.now()).toIso8601String(),
      'status': status,
      if (notes != null) 'notes': notes,
    };
    final inserted = await _client.from('interviews').insert(payload).select().single();
    return Map<String, dynamic>.from(inserted as Map);
  }

  // Legacy flow: create entry in 'interview' table which references job_posting(job_id) and employee(email)
  Future<Map<String, dynamic>> createLegacyInterview({
    required int jobId,
    required String employeeEmail,
    DateTime? scheduledDate,
    String status = 'scheduled',
    int? rating,
    String? feedback,
  }) async {
    final payload = <String, dynamic>{
      'job_id': jobId,
      'employee_email': employeeEmail,
      'scheduled_date': (scheduledDate ?? DateTime.now()).toIso8601String(),
      'status': status,
      if (rating != null) 'rating': rating,
      if (feedback != null) 'feedback': feedback,
      'created_at': DateTime.now().toIso8601String(),
    };
    final inserted = await _client.from('interview').insert(payload).select().single();
    return Map<String, dynamic>.from(inserted as Map);
  }

  Future<void> updateInterviewOutcome({
    required String interviewId, // uuid
    required int rate,
    String? notes,
  }) async {
    final newStatus = rate >= 80 ? 'hired' : 'rejected';
    final update = {
      'rate': rate,
      'status': newStatus,
      if (notes != null) 'notes': notes,
    };
    await _client.from('interviews').update(update).eq('id', interviewId);
  }

  Future<void> updateApplicationStatus({
    required dynamic applicationId, // uuid or int
    required String status,
    String? remarks,
  }) async {
    final update = {
      'status': status,
      if (remarks != null) 'remarks': remarks,
    };
    await _client.from('job_application').update(update).eq('application_id', applicationId);
  }

  Future<List<Map<String, dynamic>>> fetchApplicationsForJobs({
    required List<int> jobIds,
  }) async {
    if (jobIds.isEmpty) return [];
    final data = await _client
        .from('job_application')
        .select('*')
        .inFilter('job_id', jobIds);
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ---------------- JOB POSTINGS (Employer) ---------------- //

  Future<Map<String, dynamic>> createJobPosting({
    required String employerEmail,
    required String jobTitle,
    String? specialization,
    String? jobType,
    String? location,
    String? experienceLevel,
    String? skills, // comma separated
    num? salary,
    String? resumeUrl,
  }) async {
    final payload = {
      'employer_email': employerEmail,
      'job_title': jobTitle,
      if (specialization != null) 'specialization': specialization,
      if (jobType != null) 'job_type': jobType,
      if (location != null) 'location': location,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (skills != null) 'skills': skills,
      if (salary != null) 'salary': salary,
      if (resumeUrl != null) 'resume_url': resumeUrl,
      'profile_created_date': DateTime.now().toIso8601String(),
    };
    try {
      final inserted = await _client.from('job_posting').insert(payload).select().single();
      return Map<String, dynamic>.from(inserted as Map);
    } on PostgrestException catch (e1) {
      // Retry without select (some RLS policies disallow returning rows)
      try {
        await _client.from('job_posting').insert(payload);
        return Map<String, dynamic>.from(payload);
      } on PostgrestException catch (e2) {
        // Propagate the more specific failure
        throw Exception('Insert failed: ${e2.message}');
      } catch (e2) {
        throw Exception('Insert failed (no select): ${e2.toString()}');
      }
    } catch (e) {
      throw Exception('Insert failed: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEmployerJobs({
    required String employerEmail,
    int limit = 100,
  }) async {
    final data = await _client
        .from('job_posting')
        .select('*')
        .eq('employer_email', employerEmail)
        .order('profile_created_date', ascending: false)
        .limit(limit);
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> updateJobPosting({
    required int jobId,
    required Map<String, dynamic> fields, // keys must match DB columns
  }) async {
    if (fields.isEmpty) return;
    await _client.from('job_posting').update(fields).eq('job_id', jobId);
  }

  Future<void> deleteJobPosting({
    required int jobId,
  }) async {
    await _client.from('job_posting').delete().eq('job_id', jobId);
  }

  Future<List<int>> fetchEmployerJobIdsByEmail(String employerEmail) async {
    final data = await _client
        .from('job_posting')
        .select('job_id')
        .eq('employer_email', employerEmail);
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map((m) => m['job_id'])
        .where((v) => v != null)
        .map<int>((v) => v is int ? v : int.tryParse(v.toString()) ?? -1)
        .where((v) => v >= 0)
        .toList();
  }

  // ---------------- BASIC AUTH/PROFILE (login + employer) ---------------- //

  Future<Map<String, dynamic>?> getLoginByEmail(String email) async {
    final row = await _client
        .from('login')
        .select('full_name, email, user_type, created_at')
        .eq('email', email)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> upsertLogin({
    required String email,
    String? fullName,
    String? userType,
  }) async {
    final fallbackName = fullName ?? (email.contains('@') ? email.split('@').first : email);
    final payload = <String, dynamic>{
      'email': email,
      'full_name': fallbackName,
      'user_type': userType ?? 'employer',
      'created_at': DateTime.now().toIso8601String(),
    };
    try {
      // Upsert without selecting to avoid heavy responses and potential header issues
      await _client.from('login').upsert(payload, onConflict: 'email');
      return Map<String, dynamic>.from(payload);
    } on PostgrestException catch (e) {
      throw Exception('login upsert failed: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getEmployerByEmail(String email) async {
    final row = await _client
        .from('employer')
        .select('email, company_name, domain, company_size, phone, logo_url, created_at')
        .eq('email', email)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> upsertEmployer({
    required String email,
    String? companyName,
    String? domain,
    String? companySize,
    String? phone,
    String? logoUrl,
  }) async {
    final fallbackName = (companyName != null && companyName.trim().isNotEmpty)
        ? companyName
        : (email.contains('@') ? email.split('@').first : email);
    final values = <String, dynamic>{
      'email': email,
      'company_name': fallbackName,
      if (domain != null) 'domain': domain,
      if (companySize != null) 'company_size': companySize,
      if (phone != null) 'phone': phone,
      if (logoUrl != null) 'logo_url': logoUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
    try {
      // Upsert without selecting to avoid heavy responses and potential header issues
      await _client.from('employer').upsert(values, onConflict: 'email');
      return Map<String, dynamic>.from(values);
    } on PostgrestException catch (e) {
      throw Exception('employer upsert failed: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> updateEmployerFields({
    required String email,
    required Map<String, dynamic> fields,
  }) async {
    if (fields.isEmpty) return {'email': email};
    final res = await _client
        .from('employer')
        .update(fields)
        .eq('email', email)
        .select()
        .single();
    return Map<String, dynamic>.from(res as Map);
  }

  Future<Map<String, dynamic>> updateEmployerPhone({
    required String email,
    required String phone,
  }) async {
    final res = await _client
        .from('employer')
        .update({'phone': phone})
        .eq('email', email)
        .select()
        .single();
    return Map<String, dynamic>.from(res as Map);
  }

  // Ensures foreign key from employer -> login is satisfied
  Future<void> ensureLoginAndEmployer({
    required String email,
    String? fullName,
    String? userType,
    String? companyName,
  }) async {
    await upsertLogin(email: email, fullName: fullName, userType: userType ?? 'employer');
    await upsertEmployer(email: email, companyName: companyName);
  }
}
