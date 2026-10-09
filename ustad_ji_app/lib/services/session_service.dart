import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

class SessionService {
  static const _kUser = 'ustadji_session_v2';
  static const _kStage = 'ustadji_flow_stage';

  static Future<void> save(AuthUser user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kUser, jsonEncode(user.toMap()));
    await p.setString(_kStage, 'complete');
  }

  static Future<AuthUser?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kUser);
    if (raw == null) return null;
    try {
      return AuthUser.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUser);
    await p.remove(_kStage);
  }

  static Future<String> getStage() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kStage) ?? 'welcome';
  }

  static Future<void> setStage(String stage) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kStage, stage);
  }

  // ---- Pending signup data between wizard steps ----
  static const _kPendingName = 'ustadji_pending_name';
  static const _kPendingPhone = 'ustadji_pending_phone';
  static const _kPendingRole = 'ustadji_pending_role';
  static const _kPendingSkill = 'ustadji_pending_skill';
  static const _kPendingCity = 'ustadji_pending_city';

  static Future<void> savePending({
    String? name,
    String? phone,
    String? role,
    String? skill,
    String? city,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (name != null) await p.setString(_kPendingName, name);
    if (phone != null) await p.setString(_kPendingPhone, phone);
    if (role != null) await p.setString(_kPendingRole, role);
    if (skill != null) await p.setString(_kPendingSkill, skill);
    if (city != null) await p.setString(_kPendingCity, city);
  }

  static Future<Map<String, String?>> loadPending() async {
    final p = await SharedPreferences.getInstance();
    return {
      'name': p.getString(_kPendingName),
      'phone': p.getString(_kPendingPhone),
      'role': p.getString(_kPendingRole),
      'skill': p.getString(_kPendingSkill),
      'city': p.getString(_kPendingCity),
    };
  }

  static Future<void> clearPending() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kPendingName);
    await p.remove(_kPendingPhone);
    await p.remove(_kPendingRole);
    await p.remove(_kPendingSkill);
    await p.remove(_kPendingCity);
  }
}