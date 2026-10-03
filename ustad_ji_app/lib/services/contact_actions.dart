import 'package:url_launcher/url_launcher.dart';

class ContactActions {
  /// Pakistani numbers — all reachable via dialer / WhatsApp.
  static const List<Map<String, String>> workers = [
    {
      'name': 'Hassan Cooling',
      'phone': '+923001234567',
      'skill': 'AC Repair',
    },
    {
      'name': 'Ali AC Services',
      'phone': '+923011234568',
      'skill': 'AC Repair',
    },
    {
      'name': 'Ustad Bilal',
      'phone': '+923021234569',
      'skill': 'Electrical',
    },
    {
      'name': 'Hassan Plumbers',
      'phone': '+923031234570',
      'skill': 'Plumbing',
    },
    {
      'name': 'Usman Fridge Services',
      'phone': '+923041234571',
      'skill': 'Refrigerator Repair',
    },
  ];

  static Future<bool> call(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r"[^0-9+]"), "")}');
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  static Future<bool> whatsapp(String phone, {String? message}) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = message ?? 'Assalam o Alaikum! I need help with a repair.';
    final uri = Uri.parse(
      'https://wa.me/$cleaned?text=${Uri.encodeComponent(text)}',
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static String pickWorkerPhone(String workerName) {
    final found = workers.firstWhere(
      (w) => w['name'] == workerName,
      orElse: () => workers[1],
    );
    return found['phone']!;
  }
}