class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? skill;
  final String city;
  final double rating;
  final int totalJobs;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.skill,
    this.city = 'Lahore',
    this.rating = 4.8,
    this.totalJobs = 0,
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? skill,
    String? city,
    double? rating,
    int? totalJobs,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      skill: skill ?? this.skill,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
    );
  }
}
