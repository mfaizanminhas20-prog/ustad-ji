import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDb {
  static const _kUsers = 'ustadji_users_v1';

  static Future<List<Map<String, dynamic>>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  static Future<Map<String, dynamic>?> findByEmail(String email) async {
    final users = await all();
    final needle = email.trim().toLowerCase();
    for (final u in users) {
      if ((u['email'] ?? '').toString().toLowerCase() == needle) return u;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> findByPhone(String phone) async {
    final users = await all();
    final needle = phone.replaceAll(RegExp(r'[^0-9]'), '');
    for (final u in users) {
      final p = (u['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
      if (p == needle || p.endsWith(needle) || needle.endsWith(p)) return u;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> findByUid(String uid) async {
    final users = await all();
    for (final u in users) {
      if (u['uid'] == uid) return u;
    }
    return null;
  }

  static Future<void> upsert(Map<String, dynamic> user) async {
    final users = await all();
    final idx = users.indexWhere((u) => u['uid'] == user['uid']);
    if (idx >= 0) {
      users[idx] = user;
    } else {
      users.add(user);
    }
    await save(users);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsers);
  }
}