import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiThinkingTrace extends StatelessWidget {
  final List<String> lines;
  final bool complete;

  const AiThinkingTrace({
    super.key,
    required this.lines,
    this.complete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFF1F242E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: complete ? AppColors.success : AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                complete ? 'AGENT COMPLETE' : 'AGENT WORKING',
                style: TextStyle(
                  color: complete ? AppColors.success : AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (!complete)
                const SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...lines.asMap().entries.map((e) {
            final isLast = e.key == lines.length - 1 && !complete;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                e.value,
                style: TextStyle(
                  color: isLast ? Colors.white : const Color(0xFF98A2B3),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}