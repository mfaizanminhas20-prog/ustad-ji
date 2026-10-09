import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Platform-aware phone OTP.
/// - Android + iOS: real Firebase Phone Auth SMS
/// - Web + Desktop: simulated OTP shown in-app (SMS banner)
class PhoneAuthService {
  static const _kOtpPrefix = 'ustadji_phone_otp_';

  static bool get _useFirebase {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Send OTP. Returns a simulated code (Web) or null (Firebase/Android).
  static Future<PhoneOtpResult> sendOtp(String phone) async {
    if (_useFirebase) {
      return _sendViaFirebase(phone);
    }
    return _sendSimulated(phone);
  }

  // ────────────────────────────────────────────
  // Firebase path (Android / iOS)
  // ────────────────────────────────────────────
  static Future<PhoneOtpResult> _sendViaFirebase(String phone) async {
    final completer = Completer<PhoneOtpResult>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _normalizePhone(phone),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential cred) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpResult(
            success: true,
            isFirebase: true,
            autoVerified: true,
            verificationId: cred.verificationId,
          ));
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpResult(
            success: false,
            isFirebase: true,
            error: _mapFirebaseError(e.code),
          ));
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpResult(
            success: true,
            isFirebase: true,
            verificationId: verificationId,
          ));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpResult(
            success: true,
            isFirebase: true,
            verificationId: verificationId,
          ));
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => PhoneOtpResult(
        success: false,
        isFirebase: true,
        error: 'Timed out. Try again.',
      ),
    );
  }

  // ────────────────────────────────────────────
  // Simulated path (Web / Desktop)
  // ────────────────────────────────────────────
  static Future<PhoneOtpResult> _sendSimulated(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final r = Random();
    final code = (100000 + r.nextInt(900000)).toString();
    final key = '$_kOtpPrefix${_cleanPhone(phone)}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, code);
    await prefs.setInt(
      '${key}_exp',
      DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
    );
    return PhoneOtpResult(
      success: true,
      isFirebase: false,
      simulatedCode: code,
    );
  }

  // ────────────────────────────────────────────
  // Verify
  // ────────────────────────────────────────────
  static Future<PhoneVerifyResult> verify({
    required String phone,
    required String code,
    String? verificationId,
  }) async {
    if (_useFirebase && verificationId != null) {
      try {
        final cred = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: code,
        );
        final userCred = await FirebaseAuth.instance.signInWithCredential(cred);
        return PhoneVerifyResult(
          success: userCred.user != null,
          uid: userCred.user?.uid,
          error: userCred.user == null ? 'Verification failed' : null,
        );
      } on FirebaseAuthException catch (e) {
        return PhoneVerifyResult(
          success: false,
          error: _mapFirebaseError(e.code),
        );
      }
    }

    // Simulated verify
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kOtpPrefix${_cleanPhone(phone)}';
    final stored = prefs.getString(key);
    final exp = prefs.getInt('${key}_exp') ?? 0;

    if (stored == null) {
      return PhoneVerifyResult(success: false, error: 'No code sent.');
    }
    if (DateTime.now().millisecondsSinceEpoch > exp) {
      return PhoneVerifyResult(success: false, error: 'Code expired.');
    }
    if (stored != code.trim()) {
      return PhoneVerifyResult(success: false, error: 'Wrong code.');
    }

    await prefs.remove(key);
    await prefs.remove('${key}_exp');
    return PhoneVerifyResult(success: true);
  }

  // ────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────
  static bool isValidPakistaniPhone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return (c.length == 11 && c.startsWith('03')) ||
        (c.length == 12 && c.startsWith('923'));
  }

  static String _normalizePhone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (c.startsWith('03')) return '+92${c.substring(1)}';
    if (c.startsWith('923')) return '+$c';
    return '+$c';
  }

  static String _cleanPhone(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9]'), '');

  static String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Try later.';
      case 'quota-exceeded':
        return 'SMS limit reached for today.';
      case 'invalid-verification-code':
        return 'Wrong code.';
      case 'session-expired':
        return 'Code expired. Resend.';
      default:
        return 'Error: $code';
    }
  }
}

class PhoneOtpResult {
  final bool success;
  final bool isFirebase;
  final String? verificationId;
  final String? simulatedCode;
  final bool autoVerified;
  final String? error;

  PhoneOtpResult({
    required this.success,
    required this.isFirebase,
    this.verificationId,
    this.simulatedCode,
    this.autoVerified = false,
    this.error,
  });
}

class PhoneVerifyResult {
  final bool success;
  final String? uid;
  final String? error;
  PhoneVerifyResult({required this.success, this.uid, this.error});
}