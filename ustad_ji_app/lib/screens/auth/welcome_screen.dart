import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import 'phone_entry_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppGradients.green,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppShadows.green,
                ),
                child:
                    const Icon(Icons.handyman, color: Colors.white, size: 64),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.6, 0.6)),
              const SizedBox(height: 28),
              const Text(
                'Ustad Ji',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              const Text(
                'Trusted help, on demand.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 350.ms),
              const Spacer(),
              _bigCard(
                context,
                icon: Icons.person,
                title: 'I need help',
                subtitle: 'Book verified plumbers, electricians, AC technicians',
                color: AppColors.info,
                isCustomer: true,
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 14),
              _bigCard(
                context,
                icon: Icons.engineering,
                title: 'I want to earn',
                subtitle: 'Set your own hours, bid on jobs, get paid',
                color: AppColors.primary,
                isCustomer: false,
              ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bigCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCustomer,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () async {
          await SessionService.savePending(
            role: isCustomer ? 'customer' : 'worker',
          );
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PhoneEntryScreen(
                role: isCustomer ? 'customer' : 'worker',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}