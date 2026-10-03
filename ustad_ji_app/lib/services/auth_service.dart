import 'dart:async';
import 'dart:math';
import '../models/user_model.dart';

class AuthService {
  /// Deterministic in-memory OTP store.
  /// Same phone always produces the same code — feels real, easy to demo.
  static final Map<String, String> _otpStore = {};

  /// Pakistani mobile: 03XXXXXXXXX (11 digits) or +923XXXXXXXXX
  static bool isValidPakistaniPhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11 && cleaned.startsWith('03')) return true;
    if (cleaned.length == 12 && cleaned.startsWith('923')) return true;
    if (cleaned.length == 13 && cleaned.startsWith('0923')) return true;
    return false;
  }

  /// Normalize to +92XXXXXXXXXX format.
  static String normalizePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('03')) return '+92${cleaned.substring(1)}';
    if (cleaned.startsWith('923')) return '+$cleaned';
    if (cleaned.startsWith('0923')) return '+${cleaned.substring(1)}';
    return '+$cleaned';
  }

  /// Generate a 4-digit code tied to the phone number.
  /// Same phone -> same code. Looks like a real SMS layer.
  static String _codeForPhone(String phone) {
    final normalized = normalizePhone(phone);
    final hash = normalized.hashCode.abs();
    return (1000 + (hash % 9000)).toString();
  }

  /// "Send" OTP — returns the code so the UI can show an SMS banner.
  /// To go live: replace the body with a Twilio / MSG91 API call.
  static Future<String?> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!isValidPakistaniPhone(phone)) return null;

    final normalized = normalizePhone(phone);
    final code = _codeForPhone(normalized);
    _otpStore[normalized] = code;
    return code;
  }

  /// Verify a code against the phone.
  static bool verifyCode(String phone, String code) {
    final normalized = normalizePhone(phone);
    return _otpStore[normalized] == code.trim();
  }

  static Future<UserModel?> verifyOtp({
    required String phone,
    required String code,
    required String role,
    String name = 'Guest User',
    String? skill,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!verifyCode(phone, code)) return null;

    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: normalizePhone(phone),
      role: role,
      skill: skill,
      rating: 4.8,
      totalJobs: 12,
    );
  }
}