import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/job_response.dart';

class ApiService {
  /// Toggle: true = local mock (no backend needed).
  ///         false = hit real FastAPI backend.
  static bool useMock = true;

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  static Future<JobResponse> postJob(String description) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 900));
      return _mockJob(description);
    }

    final uri = Uri.parse('$baseUrl/post-job');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'description': description}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return JobResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Request failed [${response.statusCode}]: ${response.body}');
  }

  static JobResponse _mockJob(String description) {
    final d = description.toLowerCase();
    String category = 'General Service';
    int price = 1000;
    String? keyword;

    if (d.contains('ac') && (d.contains('leak') || d.contains('water'))) {
      category = 'AC Repair';
      price = 1500;
      keyword = 'ac leaking';
    } else if (d.contains('ac') || d.contains('air conditioner')) {
      category = 'AC Repair';
      price = 2000;
      keyword = 'air conditioner';
    } else if (d.contains('pipe') || d.contains('leak') || d.contains('tap')) {
      category = 'Plumbing';
      price = 800;
      keyword = 'pipe';
    } else if (d.contains('short') ||
        d.contains('wire') ||
        d.contains('electric')) {
      category = 'Electrical';
      price = 1200;
      keyword = 'short circuit';
    } else if (d.contains('fan')) {
      category = 'Fan Repair';
      price = 600;
      keyword = 'fan';
    } else if (d.contains('fridge') || d.contains('refrigerator')) {
      category = 'Refrigerator Repair';
      price = 2500;
      keyword = 'fridge';
    } else if (d.contains('washing') || d.contains('washer')) {
      category = 'Washing Machine Repair';
      price = 1800;
      keyword = 'washing machine';
    } else if (d.contains('geyser') || d.contains('heater')) {
      category = 'Geyser Repair';
      price = 2000;
      keyword = 'geyser';
    } else if (d.contains('lock') || d.contains('door')) {
      category = 'Carpentry';
      price = 700;
      keyword = 'lock';
    }

    final matched = keyword != null;
    final bidAmount = matched ? (price * 0.95).round() : null;

    return JobResponse(
      description: description,
      estimatedPrice: EstimatedPrice(
        matched: matched,
        category: category,
        baselinePrice: price,
        currency: 'PKR',
        matchedKeyword: keyword,
        message: matched
            ? 'Estimated baseline price for $category.'
            : 'No exact match. A technician will confirm on-site.',
      ),
      workerBid: WorkerBid(
        workerName: 'Ali AC Services',
        status: matched ? 'bid_placed' : 'ignored',
        bidAmount: bidAmount,
        reason: matched
            ? 'Agent matched "$category" and placed a competitive bid.'
            : 'No confident price estimate — skipping job.',
      ),
    );
  }
}
