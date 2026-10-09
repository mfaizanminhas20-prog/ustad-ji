import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class LanguageSwitcher extends StatelessWidget {
  final bool dark;
  const LanguageSwitcher({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appLanguage,
      builder: (_, __) {
        return GestureDetector(
          onTap: () => _showSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkElevated : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language,
                    size: 16,
                    color: dark ? AppColors.darkText : AppColors.textPrimary),
                const SizedBox(width: 5),
                Text(
                  appLanguage.langLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: dark ? AppColors.darkText : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _langTile(context, 'English', 'EN', AppLang.english),
            const SizedBox(height: 8),
            _langTile(context, 'Urdu', 'UR', AppLang.urdu),
            const SizedBox(height: 8),
            _langTile(context, 'Roman Urdu', 'RM', AppLang.roman),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _langTile(BuildContext context, String label, String code, AppLang lang) {
    final selected = appLanguage.current == lang;
    return GestureDetector(
      onTap: () {
        appLanguage.setLang(lang);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}