import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/primary_text_field.dart';
import '../customer/home_screen.dart';
import '../worker/worker_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  String _role = 'customer';
  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final code = await AuthService.sendOtp(_phone.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);

    if (code == null) {
      setState(() => _error = 'Please enter a valid phone number.');
      return;
    }

    setState(() {
      _otpSent = true;
      _otp.text = '';
    });

    _showSmsBanner(code);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _otp.text = code);
    });
  }

  void _showSmsBanner(String code) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sms, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'New SMS - Ustad Ji',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your code is $code. Do not share.',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F242E),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await AuthService.verifyOtp(
      phone: _phone.text.trim(),
      code: _otp.text.trim(),
      role: _role,
      name: _name.text.trim().isEmpty
          ? (_role == 'worker' ? 'Ali AC Services' : 'Guest User')
          : _name.text.trim(),
      skill: _role == 'worker' ? 'AC Repair' : null,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      setState(() => _error = 'Enter a 4-digit code.');
      return;
    }

    appState.login(user);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => user.role == 'worker'
          ? const WorkerDashboard()
          : const CustomerHomeScreen(),
    ));
  }

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.handyman,
                    color: AppColors.primary, size: 32),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.6, 0.6)),
              const SizedBox(height: 24),
              const Text(
                'Welcome to Ustad Ji',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              const Text(
                'Sign in to book a trusted ustad or start accepting jobs.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 30),

              PrimaryTextField(
                controller: _name,
                label: 'Your name (optional)',
                hint: 'e.g. Ahmed Khan',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              PrimaryTextField(
                controller: _phone,
                label: 'Phone number',
                hint: '03XX-XXXXXXX',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              if (_otpSent) ...[
                PrimaryTextField(
                  controller: _otp,
                  label: 'Verification code',
                  hint: 'Enter 4 digits',
                  prefixIcon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'I am a',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _roleCard('customer', Icons.person, 'Customer')),
                  const SizedBox(width: 10),
                  Expanded(
                      child:
                          _roleCard('worker', Icons.engineering, 'Worker')),
                ],
              ),

              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border:
                        Border.all(color: AppColors.danger.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              GradientButton(
                label: _otpSent ? 'Verify & Continue' : 'Send Code',
                icon: _otpSent ? Icons.check : Icons.sms_outlined,
                loading: _loading,
                onPressed: _otpSent ? _verify : _sendOtp,
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Demo mode: any 4-digit code works',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String role, IconData icon, String label) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:
                    selected ? AppColors.primary : AppColors.textSecondary,
                size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color:
                    selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}