import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/api_job.dart';
import '../models/api_bid.dart';

/// HTTP client for the new REST API (`/api/*`).
/// Falls back gracefully when the backend is unreachable.
class JobApiService {
  /// Point this at your deployed backend to go live.
  static const String _prodBase = 'https://ustad-ji-api.onrender.com';

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  /// Set to true in production to hit the deployed backend.
  static const bool useProd = false;

  static String get _base => useProd ? _prodBase : baseUrl;

  // ─────────────────────────────────────────
  // USERS
  // ─────────────────────────────────────────
  static Future<bool> upsertUser({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    String? skill,
    String city = 'Lahore',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/users'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'uid': uid,
              'full_name': fullName,
              'email': email,
              'phone': phone,
              'role': role,
              'skill': skill,
              'city': city,
            }),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // JOBS
  // ─────────────────────────────────────────
  static Future<ApiJob?> createJob({
    required String customerUid,
    required String customerName,
    required String customerPhone,
    required String description,
    required String category,
    required int baselinePrice,
    String address = 'Lahore',
    double? lat,
    double? lng,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/jobs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'customer_uid': customerUid,
              'customer_name': customerName,
              'customer_phone': customerPhone,
              'description': description,
              'category': category,
              'baseline_price': baselinePrice,
              'address': address,
              'lat': lat,
              'lng': lng,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return ApiJob.fromMap(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<ApiJob>> listOpenJobs({int limit = 50}) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/jobs?status=open&limit=$limit'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list
            .map((e) => ApiJob.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<ApiJob?> getJob(int jobId) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/jobs/$jobId'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return ApiJob.fromMap(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateStatus(int jobId, String status) async {
    try {
      final res = await http
          .patch(
            Uri.parse('$_base/api/jobs/$jobId/status?status=$status'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // BIDS
  // ─────────────────────────────────────────
  static Future<ApiBid?> placeBid({
    required int jobId,
    required String workerUid,
    required String workerName,
    required String workerPhone,
    required String workerSkill,
    required int amount,
    double workerRating = 5.0,
    double distanceKm = 1.0,
    String? message,
    bool isAutoBid = false,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_base/api/jobs/$jobId/bids'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'worker_uid': workerUid,
              'worker_name': workerName,
              'worker_phone': workerPhone,
              'worker_rating': workerRating,
              'worker_skill': workerSkill,
              'amount': amount,
              'distance_km': distanceKm,
              'message': message,
              'is_auto_bid': isAutoBid,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        return ApiBid.fromMap(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<ApiBid>> listBids(int jobId) async {
    try {
      final res = await http
          .get(Uri.parse('$_base/api/jobs/$jobId/bids'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list
            .map((e) => ApiBid.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> acceptBid(int jobId, int bidId) async {
    try {
      final res = await http
          .post(Uri.parse('$_base/api/jobs/$jobId/accept/$bidId'))
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // HEALTH
  // ─────────────────────────────────────────
  static Future<bool> isBackendUp() async {
    try {
      final res = await http
          .get(Uri.parse('$_base/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}