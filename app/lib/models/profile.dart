class Profile {
  final String id;
  final String name;
  final String title;
  final String email;
  final String avatarUrl;
  final int experience;
  final List<String> skills;

  Profile({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.avatarUrl,
    required this.experience,
    required this.skills,
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    String s(String k) => (m[k] ?? '').toString();
    final rawSkills = m['skills'];
    List<String> skills;
    if (rawSkills == null) skills = [];
    else if (rawSkills is List) skills = List<String>.from(rawSkills.map((e) => e.toString()));
    else skills = rawSkills.toString().split(',').map((e) => e.trim()).where((e)=>e.isNotEmpty).toList();

    return Profile(
      id: s('id'),
      name: s('full_name').isNotEmpty ? s('full_name') : s('name'),
      title: s('job_title').isNotEmpty ? s('job_title') : s('title'),
      email: s('email'),
      avatarUrl: s('avatar_url'),
      experience: int.tryParse(s('experience')) ?? 0,
      skills: skills,
    );
  }
}