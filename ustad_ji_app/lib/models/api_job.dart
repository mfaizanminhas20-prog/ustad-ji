class ApiJob {
  final int id;
  final String customerUid;
  final String customerName;
  final String customerPhone;
  final String description;
  final String category;
  final int baselinePrice;
  final String address;
  final String status;
  final int? acceptedBidId;
  final DateTime createdAt;
  final int bidCount;

  ApiJob({
    required this.id,
    required this.customerUid,
    required this.customerName,
    required this.customerPhone,
    required this.description,
    required this.category,
    required this.baselinePrice,
    required this.address,
    required this.status,
    this.acceptedBidId,
    required this.createdAt,
    required this.bidCount,
  });

  factory ApiJob.fromMap(Map<String, dynamic> m) => ApiJob(
        id: m['id'] ?? 0,
        customerUid: m['customer_uid'] ?? '',
        customerName: m['customer_name'] ?? '',
        customerPhone: m['customer_phone'] ?? '',
        description: m['description'] ?? '',
        category: m['category'] ?? '',
        baselinePrice: m['baseline_price'] ?? 0,
        address: m['address'] ?? '',
        status: m['status'] ?? 'requested',
        acceptedBidId: m['accepted_bid_id'],
        createdAt:
            DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
        bidCount: m['bid_count'] ?? 0,
      );
}