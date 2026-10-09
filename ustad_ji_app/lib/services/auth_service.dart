import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';
import 'local_db.dart';

class AuthResult {
  final bool success;
  final String? error;
  final AuthUser? user;
  final String? otp;
  AuthResult({required this.success, this.error, this.user, this.otp});
}

class AuthService {
  static const _kOtpPrefix = 'ustadji_otp_';

  static bool isValidPakistaniPhone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return (c.length == 11 && c.startsWith('03')) ||
        (c.length == 12 && c.startsWith('923'));
  }

  static String normalizePhone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (c.startsWith('03')) return '+92${c.substring(1)}';
    if (c.startsWith('923')) return '+$c';
    return '+$c';
  }

  static bool isValidEmail(String email) =>
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email.trim());

  static int passwordScore(String pwd) {
    if (pwd.isEmpty) return 0;
    int s = 0;
    if (pwd.length >= 8) s++;
    if (pwd.length >= 12) s++;
    if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) s++;
    if (RegExp(r'[0-9]').hasMatch(pwd)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd)) s++;
    return s > 4 ? 4 : s;
  }

  static String passwordStrengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
    }
    return 'Weak';
  }

  static String? validatePassword(String pwd) {
    if (pwd.length < 8) return 'Password must be 8+ characters.';
    if (!RegExp(r'[A-Z]').hasMatch(pwd)) return 'Add an uppercase letter.';
    if (!RegExp(r'[a-z]').hasMatch(pwd)) return 'Add a lowercase letter.';
    if (!RegExp(r'[0-9]').hasMatch(pwd)) return 'Add a number.';
    return null;
  }

  static String _hash(String pwd, String salt) =>
      sha256.convert(utf8.encode('$salt::$pwd')).toString();

  static String _salt() {
    final r = Random.secure();
    return List.generate(24, (_) => r.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static Future<AuthResult> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? skill,
    String city = 'Lahore',
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (fullName.trim().length < 3) {
      return AuthResult(success: false, error: 'Enter your full name.');
    }
    if (!isValidEmail(email)) {
      return AuthResult(success: false, error: 'Enter a valid email.');
    }
    if (!isValidPakistaniPhone(phone)) {
      return AuthResult(
          success: false,
          error: 'Enter valid Pakistani number (03001234567).');
    }
    final pe = validatePassword(password);
    if (pe != null) return AuthResult(success: false, error: pe);
    if (securityAnswer.trim().length < 2) {
      return AuthResult(
          success: false, error: 'Security answer is too short.');
    }

    if (await LocalDb.findByEmail(email) != null) {
      return AuthResult(
          success: false, error: 'This email is already registered.');
    }
    final normPhone = normalizePhone(phone);
    if (await LocalDb.findByPhone(normPhone) != null) {
      return AuthResult(
          success: false, error: 'This phone is already registered.');
    }

    final salt = _salt();
    final hash = _hash(password, salt);
    final uid = DateTime.now().millisecondsSinceEpoch.toString();

    final userMap = <String, dynamic>{
      'uid': uid,
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': normPhone,
      'role': role,
      'skill': skill,
      'city': city,
      'rating': 5.0,
      'totalJobs': 0,
      'salt': salt,
      'hash': hash,
      'securityQuestion': securityQuestion,
      'securityAnswerHash': _hash(securityAnswer.toLowerCase().trim(), salt),
      'createdAt': DateTime.now().toIso8601String(),
    };

    await LocalDb.upsert(userMap);

    final code = await _generateOtp(normPhone);
    return AuthResult(
      success: true,
      otp: code,
      user: AuthUser.fromMap(userMap),
    );
  }

  static Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (identifier.trim().isEmpty) {
      return AuthResult(success: false, error: 'Enter email or phone.');
    }
    if (password.isEmpty) {
      return AuthResult(success: false, error: 'Enter your password.');
    }

    Map<String, dynamic>? user = await LocalDb.findByEmail(identifier);
    user ??= await LocalDb.findByPhone(identifier);

    if (user == null) {
      return AuthResult(
          success: false, error: 'No account found. Please sign up.');
    }

    final salt = user['salt'] as String? ?? '';
    final expected = user['hash'] as String? ?? '';
    final actual = _hash(password, salt);

    if (actual != expected) {
      return AuthResult(success: false, error: 'Incorrect password.');
    }

    return AuthResult(success: true, user: AuthUser.fromMap(user));
  }

  static Future<String> _generateOtp(String phone) async {
    final r = Random();
    final code = (100000 + r.nextInt(900000)).toString();
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kOtpPrefix${phone.replaceAll(RegExp(r"[^0-9]"), "")}';
    await prefs.setString(key, code);
    await prefs.setInt(
      '${key}_exp',
      DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
    );
    return code;
  }

  static Future<String?> resendOtp(String phone) async =>
      _generateOtp(normalizePhone(phone));

  static Future<bool> verifyOtp(String phone, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '$_kOtpPrefix${normalizePhone(phone).replaceAll(RegExp(r"[^0-9]"), "")}';
    final stored = prefs.getString(key);
    final exp = prefs.getInt('${key}_exp') ?? 0;
    if (stored == null) return false;
    if (DateTime.now().millisecondsSinceEpoch > exp) return false;
    if (stored != code.trim()) return false;
    await prefs.remove(key);
    await prefs.remove('${key}_exp');
    return true;
  }

  static Future<String?> getSecurityQuestion(String email) async {
    final user = await LocalDb.findByEmail(email);
    return user?['securityQuestion'] as String?;
  }

  static Future<AuthResult> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  }) async {
    final user = await LocalDb.findByEmail(email);
    if (user == null) {
      return AuthResult(success: false, error: 'No account with that email.');
    }
    final pe = validatePassword(newPassword);
    if (pe != null) return AuthResult(success: false, error: pe);

    final salt = user['salt'] as String? ?? '';
    final expected = user['securityAnswerHash'] as String? ?? '';
    final actual = _hash(answer.toLowerCase().trim(), salt);
    if (actual != expected) {
      return AuthResult(success: false, error: 'Incorrect answer.');
    }

    user['hash'] = _hash(newPassword, salt);
    await LocalDb.upsert(user);
    return AuthResult(success: true, user: AuthUser.fromMap(user));
  }

  static Future<AuthUser?> getUserByPhone(String phone) async {
    final user = await LocalDb.findByPhone(phone);
    if (user == null) return null;
    return AuthUser.fromMap(user);
  }

  static const List<String> securityQuestions = [
    'What is your mother\'s maiden name?',
    'What was the name of your first pet?',
    'What city were you born in?',
    'What is your favourite dish?',
    'What was your childhood nickname?',
  ];

  // Used by the new wizard — creates a phone-only account with defaults.
  static Future<AuthResult> signupWithPhone({
    required String fullName,
    required String phone,
    required String role,
    String? skill,
    String city = 'Lahore',
  }) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final email = '${role}_$stamp@ustadji.phone';
    return signup(
      fullName: fullName,
      email: email,
      phone: phone,
      password: 'PhoneUser@$stamp',
      role: role,
      skill: skill,
      city: city,
      securityQuestion: 'What city were you born in?',
      securityAnswer: city,
    );
  }
}