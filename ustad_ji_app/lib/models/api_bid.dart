class ApiBid {
  final int id;
  final int jobId;
  final String workerUid;
  final String workerName;
  final String workerPhone;
  final double workerRating;
  final String workerSkill;
  final int amount;
  final double distanceKm;
  final String? message;
  final bool isAutoBid;
  final DateTime createdAt;

  ApiBid({
    required this.id,
    required this.jobId,
    required this.workerUid,
    required this.workerName,
    required this.workerPhone,
    required this.workerRating,
    required this.workerSkill,
    required this.amount,
    required this.distanceKm,
    this.message,
    required this.isAutoBid,
    required this.createdAt,
  });

  factory ApiBid.fromMap(Map<String, dynamic> m) => ApiBid(
        id: m['id'] ?? 0,
        jobId: m['job_id'] ?? 0,
        workerUid: m['worker_uid'] ?? '',
        workerName: m['worker_name'] ?? '',
        workerPhone: m['worker_phone'] ?? '',
        workerRating: (m['worker_rating'] ?? 5.0).toDouble(),
        workerSkill: m['worker_skill'] ?? 'General',
        amount: m['amount'] ?? 0,
        distanceKm: (m['distance_km'] ?? 1.0).toDouble(),
        message: m['message'],
        isAutoBid: m['is_auto_bid'] ?? false,
        createdAt:
            DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
      );
}