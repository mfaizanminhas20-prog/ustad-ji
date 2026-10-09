class AuthUser {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? skill;
  final String city;
  final double rating;
  final int totalJobs;
  final DateTime createdAt;

  AuthUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.skill,
    this.city = 'Lahore',
    this.rating = 5.0,
    this.totalJobs = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'skill': skill,
        'city': city,
        'rating': rating,
        'totalJobs': totalJobs,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuthUser.fromMap(Map<String, dynamic> m) => AuthUser(
        uid: m['uid'] ?? '',
        fullName: m['fullName'] ?? '',
        email: m['email'] ?? '',
        phone: m['phone'] ?? '',
        role: m['role'] ?? 'customer',
        skill: m['skill'],
        city: m['city'] ?? 'Lahore',
        rating: (m['rating'] ?? 5.0).toDouble(),
        totalJobs: m['totalJobs'] ?? 0,
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );
}