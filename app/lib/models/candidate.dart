class Candidate {
  final String id;
  final String name;
  final String title;
  final String email;
  final String avatarUrl;
  final int experience; // years
  final List<String> skills;

  Candidate({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.avatarUrl,
    required this.experience,
    required this.skills,
  });

  factory Candidate.fromMap(Map<String, dynamic> m) {
    return Candidate(
      id: (m['id'] ?? '').toString(),
      name: m['name'] ?? '',
      title: m['title'] ?? '',
      email: m['email'] ?? '',
      avatarUrl: m['avatar_url'] ?? '',
      experience: m['experience'] is int ? m['experience'] : int.tryParse('${m['experience']}') ?? 0,
      skills: (m['skills'] is List) ? List<String>.from(m['skills']) : (m['skills'] != null ? (m['skills'] as String).split(',').map((s)=>s.trim()).toList() : []),
    );
  }
}