import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/phone_auth_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'otp_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  final String role;
  const PhoneEntryScreen({super.key, required this.role});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _agreed = true;

  String _formatPhone(String raw) {
    final c = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (c.length <= 4) return c;
    if (c.length <= 7) return '${c.substring(0, 4)}-${c.substring(4)}';
    return '${c.substring(0, 4)}-${c.substring(4, 11 > c.length ? c.length : 11)}';
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    final raw = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (!PhoneAuthService.isValidPakistaniPhone(raw)) {
      setState(() => _error =
          'Enter a valid Pakistani number (e.g. 0300-1234567).');
      return;
    }
    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await PhoneAuthService.sendOtp(raw);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.error ?? 'Failed to send OTP.');
      return;
    }

    await SessionService.savePending(phone: raw);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: raw,
          role: widget.role,
          verificationId: result.verificationId,
          simulatedCode: result.simulatedCode,
          autoVerified: result.autoVerified,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phone.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.role == 'worker'
                    ? 'We\'ll send a code to verify. Use a number customers can reach you on.'
                    : 'We\'ll send a 6-digit code to verify your number.',
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇵🇰', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text(
                          '+92',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                      ],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '0300-1234567',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreed,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _agreed = v ?? true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
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
                ),
              if (_error != null) const SizedBox(height: 14),

              GradientButton(
                label: 'Send Code',
                icon: Icons.sms_outlined,
                loading: _loading,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}