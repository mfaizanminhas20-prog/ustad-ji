class EstimatedPrice {
  final bool matched;
  final String category;
  final int baselinePrice;
  final String currency;
  final String? matchedKeyword;
  final String message;

  EstimatedPrice({
    required this.matched,
    required this.category,
    required this.baselinePrice,
    required this.currency,
    required this.message,
    this.matchedKeyword,
  });

  factory EstimatedPrice.fromJson(Map<String, dynamic> json) {
    return EstimatedPrice(
      matched: json['matched'] ?? false,
      category: json['category'] ?? 'General',
      baselinePrice: json['baseline_price'] ?? 0,
      currency: json['currency'] ?? 'PKR',
      matchedKeyword: json['matched_keyword'],
      message: json['message'] ?? '',
    );
  }
}

class WorkerBid {
  final String workerName;
  final String status;
  final int? bidAmount;
  final String reason;

  WorkerBid({
    required this.workerName,
    required this.status,
    required this.reason,
    this.bidAmount,
  });

  bool get isPlaced => status == 'bid_placed';

  factory WorkerBid.fromJson(Map<String, dynamic> json) {
    return WorkerBid(
      workerName: json['worker_name'] ?? 'AI Worker',
      status: json['status'] ?? 'ignored',
      bidAmount: json['bid_amount'],
      reason: json['reason'] ?? '',
    );
  }
}

class JobResponse {
  final String description;
  final EstimatedPrice estimatedPrice;
  final WorkerBid workerBid;

  JobResponse({
    required this.description,
    required this.estimatedPrice,
    required this.workerBid,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      description: json['description'] ?? '',
      estimatedPrice:
          EstimatedPrice.fromJson(json['estimated_price'] ?? {}),
      workerBid: WorkerBid.fromJson(json['worker_bid'] ?? {}),
    );
  }
}