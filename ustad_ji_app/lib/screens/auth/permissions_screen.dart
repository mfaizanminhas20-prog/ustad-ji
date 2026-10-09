import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/session_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/permission_card.dart';
import 'all_set_screen.dart';

class PermissionsScreen extends StatefulWidget {
  final String role;
  const PermissionsScreen({super.key, required this.role});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _location = false;
  bool _notifications = false;

  Future<void> _askLocation() async {
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      setState(() => _location = (p == LocationPermission.whileInUse ||
          p == LocationPermission.always));
    } catch (_) {
      setState(() => _location = true); // Web often blocks; treat as granted
    }
  }

  Future<void> _askNotifications() async {
    // Simple demo — just toggles the visual state
    setState(() => _notifications = true);
  }

  Future<void> _continue() async {
    final user = await SessionService.load();
    if (user != null) {
      appState.login(user);
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AllSetScreen(role: widget.role),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'A few permissions',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'These make Ustad Ji work better. You can change them anytime in Settings.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              PermissionCard(
                icon: Icons.location_on_outlined,
                title: 'Location',
                description:
                    'Find ustads near you and show live tracking during a job.',
                granted: _location,
                onTap: _askLocation,
                color: AppColors.info,
              ),
              const SizedBox(height: 14),
              PermissionCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                description:
                    'Get alerts when a bid is placed, your ustad is on the way, or a job is done.',
                granted: _notifications,
                onTap: _askNotifications,
                color: AppColors.accent,
              ),

              const Spacer(),

              GradientButton(
                label: _location ? 'Continue' : 'Skip for now',
                icon: Icons.arrow_forward,
                onPressed: _continue,
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _continue,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}