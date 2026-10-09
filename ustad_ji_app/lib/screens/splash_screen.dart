import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/session_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'auth/welcome_screen.dart';
import 'customer/home_screen.dart';
import 'worker/worker_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 1600));

    final savedUser = await SessionService.load();
    if (savedUser != null) {
      appState.login(savedUser);
    }

    if (!mounted) return;

    Widget next;
    if (savedUser != null) {
      next = savedUser.role == 'worker'
          ? const WorkerDashboard()
          : const CustomerHomeScreen();
    } else {
      next = const WelcomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(Icons.handyman,
                  size: 60, color: AppColors.primary),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.6, 0.6)),
            const SizedBox(height: 26),
            const Text(
              'Ustad Ji',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Trusted help, on demand.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}