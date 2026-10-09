import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/session_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confetti.dart';
import '../../widgets/gradient_button.dart';
import '../customer/home_screen.dart';
import '../worker/worker_dashboard.dart';

class AllSetScreen extends StatelessWidget {
  final String role;
  const AllSetScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ConfettiOverlay()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppGradients.green,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.green,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 64),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.4, 0.4)),
                  const SizedBox(height: 30),
                  const Text(
                    'You\'re all set!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  const SizedBox(height: 10),
                  Text(
                    role == 'worker'
                        ? 'Welcome aboard, ustad. Let\'s get you your first job.'
                        : 'Welcome to Ustad Ji. Let\'s find you the right help.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 450.ms),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Explore Ustad Ji',
                      icon: Icons.rocket_launch,
                      onPressed: () async {
                        await SessionService.clearPending();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => role == 'worker'
                                ? const WorkerDashboard()
                                : const CustomerHomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}