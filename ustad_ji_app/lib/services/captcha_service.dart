import 'dart:math';

class CaptchaChallenge {
  final String question;
  final int answer;
  final String type;
  CaptchaChallenge({required this.question, required this.answer, required this.type});
}

class CaptchaService {
  static final Random _r = Random.secure();

  /// Generate a fresh challenge. Pick from 3 types for variety.
  static CaptchaChallenge generate() {
    final type = _r.nextInt(3);
    if (type == 0) return _math();
    if (type == 1) return _word();
    return _mixed();
  }

  static CaptchaChallenge _math() {
    final a = _r.nextInt(20) + 3;
    final b = _r.nextInt(15) + 2;
    final op = _r.nextInt(2);
    if (op == 0) {
      return CaptchaChallenge(
        question: 'What is $a + $b?',
        answer: a + b,
        type: 'math',
      );
    }
    final big = a > b ? a : b;
    final small = a > b ? b : a;
    return CaptchaChallenge(
      question: 'What is $big - $small?',
      answer: big - small,
      type: 'math',
    );
  }

  static CaptchaChallenge _word() {
    const words = [
      'USTAD', 'PAKISTAN', 'LAHORE', 'KARACHI', 'REPAIR',
      'PLUMBER', 'WELDER', 'ELECTRIC', 'PIPE', 'FAN',
    ];
    final w = words[_r.nextInt(words.length)];
    final idx = _r.nextInt(w.length);
    final letter = w[idx];
    // Count of that letter in the word
    int count = 0;
    for (final c in w.split('')) {
      if (c == letter) count++;
    }
    return CaptchaChallenge(
      question: 'In "$w", how many times does the letter "$letter" appear?',
      answer: count,
      type: 'word',
    );
  }

  static CaptchaChallenge _mixed() {
    final n = _r.nextInt(9) + 2;
    return CaptchaChallenge(
      question: 'What is $n times $n?',
      answer: n * n,
      type: 'mixed',
    );
  }

  /// Case-insensitive verification.
  static bool verify(CaptchaChallenge challenge, String userAnswer) {
    final cleaned = userAnswer.trim().toLowerCase();
    return cleaned == challenge.answer.toString().toLowerCase();
  }
}