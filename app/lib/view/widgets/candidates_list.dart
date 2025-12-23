import 'package:flutter/material.dart';
import 'package:app/data/supabase_service.dart';
import 'package:app/models/profile.dart';

class CandidatesList extends StatefulWidget {
  const CandidatesList({super.key});
  @override
  State<CandidatesList> createState() => _CandidatesListState();
}

class _CandidatesListState extends State<CandidatesList> {
  final SupabaseService _svc = SupabaseService();
  late Future<List<Profile>> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc
        .fetchProfiles(limit: 50)
        .then((rows) => rows.map((m) => Profile.fromMap(m)).toList())
        .catchError((error) {
      debugPrint('⚠️ fetchProfiles error: $error');
      return <Profile>[]; // Return empty list on network error
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Profile>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading profiles: ${snapshot.error}'),
          );
        }
        final profiles = snapshot.data ?? [];
        if (profiles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No candidates found'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profiles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = profiles[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: p.avatarUrl.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.title} • ${p.experience} yrs'),
                isThreeLine: true,
                trailing: Text(p.email, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  // TODO: navigate to profile detail page
                },
              ),
            );
          },
        );
      },
    );
  }
}