import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  const PasswordStrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = AuthService.passwordScore(password);
    final label = AuthService.passwordStrengthLabel(score);
    final colors = [
      AppColors.danger,
      AppColors.danger,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
    ];
    final color = password.isEmpty ? AppColors.border : colors[score];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              password.isEmpty ? '' : label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _hint(score),
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  String _hint(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Use 8+ chars with upper, lower, and number.';
      case 2:
        return 'Add symbols (!@#) and go 12+ chars.';
      case 3:
        return 'Almost there — add a symbol.';
      case 4:
        return 'Strong password.';
      default:
        return '';
    }
  }
}