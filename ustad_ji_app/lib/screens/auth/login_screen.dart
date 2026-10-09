import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../customer/home_screen.dart';
import '../worker/worker_dashboard.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _pwd = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await AuthService.login(
      identifier: _id.text,
      password: _pwd.text,
    );

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.error;
      });
      return;
    }

    await SessionService.save(result.user!);
    appState.login(result.user!);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => result.user!.role == 'worker'
          ? const WorkerDashboard()
          : const CustomerHomeScreen(),
    ));
  }

  Future<void> _guest({required bool asWorker}) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final email = asWorker
        ? 'worker_$stamp@ustadji.app'
        : 'customer_$stamp@ustadji.app';
    final phone = asWorker ? '03009990001' : '03009990002';
    final name = asWorker ? 'Demo Worker' : 'Demo Customer';

    final result = await AuthService.signup(
      fullName: name,
      email: email,
      phone: phone,
      password: 'Demo@1234',
      role: asWorker ? 'worker' : 'customer',
      skill: asWorker ? 'AC Repair' : null,
      securityQuestion: 'What city were you born in?',
      securityAnswer: 'Lahore',
    );

    if (!result.success) {
      final fb = await AuthService.login(
          identifier: email, password: 'Demo@1234');
      if (fb.success) {
        await SessionService.save(fb.user!);
        appState.login(fb.user!);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => asWorker
              ? const WorkerDashboard()
              : const CustomerHomeScreen(),
        ));
        return;
      }
      setState(() {
        _loading = false;
        _error = result.error;
      });
      return;
    }

    await SessionService.save(result.user!);
    appState.login(result.user!);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => asWorker
          ? const WorkerDashboard()
          : const CustomerHomeScreen(),
    ));
  }

  @override
  void dispose() {
    _id.dispose();
    _pwd.dispose();
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppGradients.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ustad Ji',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your email or Pakistani phone number.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 32),

              TextField(
                controller: _id,
                keyboardType: TextInputType.emailAddress,
                decoration: _deco(
                  label: 'Email or phone',
                  hint: 'you@example.com or 03001234567',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _pwd,
                obscureText: _obscure,
                decoration: _deco(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25)),
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
                ).animate().fadeIn().shakeX(),

              if (_error != null) const SizedBox(height: 14),

              GradientButton(
                label: 'Log In',
                icon: Icons.login,
                loading: _loading,
                onPressed: _login,
              ),

              const SizedBox(height: 24),

              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _socialBtn(
                      icon: Icons.person,
                      label: 'Guest',
                      color: AppColors.info,
                      onTap: () => _guest(asWorker: false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _socialBtn(
                      icon: Icons.engineering,
                      label: 'Demo Worker',
                      color: AppColors.accent,
                      onTap: () => _guest(asWorker: true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt, size: 18),
                  label: const Text('Create New Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.bg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }
}