import 'package:flutter/material.dart';

enum AppLang { english, urdu, roman }

class AppLanguage extends ChangeNotifier {
  AppLang _current = AppLang.english;
  AppLang get current => _current;

  void setLang(AppLang lang) {
    _current = lang;
    notifyListeners();
  }

  String t(String key) {
    final map = _translations[key];
    if (map == null) return key;
    switch (_current) {
      case AppLang.english:
        return map['en'] ?? key;
      case AppLang.urdu:
        return map['ur'] ?? map['en'] ?? key;
      case AppLang.roman:
        return map['ro'] ?? map['en'] ?? key;
    }
  }

  String get langLabel {
    switch (_current) {
      case AppLang.english:
        return 'EN';
      case AppLang.urdu:
        return 'UR';
      case AppLang.roman:
        return 'RM';
    }
  }

  static const Map<String, Map<String, String>> _translations = {
    'hi': {'en': 'Hi', 'ur': 'السلام علیکم', 'ro': 'Assalam o Alaikum'},
    'what_help': {
      'en': 'What do you need help with?',
      'ur': 'آپ کو کس چیز میں مدد چاہیے؟',
      'ro': 'Aap ko kis cheez mein madad chahiye?',
    },
    'describe_hint': {
      'en': 'Describe your problem...',
      'ur': 'اپنا مسئلہ بیان کریں...',
      'ro': 'Apna masla bayan karein...',
    },
    'quick_picks': {
      'en': 'QUICK PICKS',
      'ur': 'فوری انتخاب',
      'ro': 'Fori Intikhab',
    },
    'services': {'en': 'Services', 'ur': 'خدمات', 'ro': 'Khidmaat'},
    'recent_bookings': {
      'en': 'Recent Bookings',
      'ur': 'حالیہ بکنگز',
      'ro': 'Haal ki Bookings',
    },
    'see_all': {'en': 'See all', 'ur': 'سب دیکھیں', 'ro': 'Sab dekhein'},
    'call': {'en': 'Call', 'ur': 'کال کریں', 'ro': 'Call karein'},
    'whatsapp': {'en': 'WhatsApp', 'ur': 'واٹس ایپ', 'ro': 'WhatsApp'},
    'confirm_booking': {
      'en': 'Confirm Booking',
      'ur': 'بکنگ کی تصدیق کریں',
      'ro': 'Booking confirm karein',
    },
    'why_best': {
      'en': 'Why this is best for you',
      'ur': 'یہ آپ کے لیے بہترین کیوں ہے',
      'ro': 'Ye aap ke liye behtareen kyun hai',
    },
    'evidence': {
      'en': 'Evidence used',
      'ur': 'استعمال شدہ ثبوت',
      'ro': 'Istemaal shuda saboot',
    },
  };
}

final appLanguage = AppLanguage();