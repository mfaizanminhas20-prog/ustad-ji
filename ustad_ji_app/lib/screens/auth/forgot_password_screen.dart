import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/password_strength_meter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _answer = TextEditingController();
  final _newPwd = TextEditingController();

  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _question;

  Future<void> _loadQuestion() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final q = await AuthService.getSecurityQuestion(_email.text);
    setState(() => _loading = false);
    if (q == null) {
      setState(() => _error = 'No account found with that email.');
      return;
    }
    setState(() {
      _question = q;
      _step = 1;
    });
  }

  Future<void> _reset() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await AuthService.resetPassword(
      email: _email.text,
      answer: _answer.text,
      newPassword: _newPwd.text,
    );
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.error);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset. Please log in.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _email.dispose();
    _answer.dispose();
    _newPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                _step == 0 ? 'Enter your email' : 'Answer security question',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _step == 0
                    ? 'We will show your security question.'
                    : _question ?? '',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              if (_step == 0) ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _deco('Email', 'you@example.com',
                      Icons.email_outlined),
                ),
              ] else ...[
                TextField(
                  controller: _answer,
                  decoration: _deco('Answer', 'Your answer',
                      Icons.help_outline),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _newPwd,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                  decoration: _deco('New password', 'Create a strong password',
                      Icons.lock_outline),
                ),
                const SizedBox(height: 10),
                PasswordStrengthMeter(password: _newPwd.text),
              ],

              const SizedBox(height: 20),
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
                ),
              if (_error != null) const SizedBox(height: 14),

              GradientButton(
                label: _step == 0 ? 'Continue' : 'Reset Password',
                icon: _step == 0 ? Icons.arrow_forward : Icons.check,
                loading: _loading,
                onPressed: _step == 0 ? _loadQuestion : _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
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