import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/phone_auth_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/otp_box.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;
  final String? verificationId;
  final String? simulatedCode;
  final bool autoVerified;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
    this.verificationId,
    this.simulatedCode,
    this.autoVerified = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpKey = GlobalKey<OtpBoxState>();
  bool _loading = false;
  String? _error;
  int _countdown = 60;
  Timer? _timer;
  String? _code;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // On Web/Desktop, show simulated SMS banner
    if (widget.simulatedCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSmsBanner(widget.simulatedCode!);
        // Auto-fill after 1.2s to simulate SMS autofill
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) _code = widget.simulatedCode;
        });
      });
    }
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) t.cancel();
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
                color: Colors.white.withValues(alpha: 0.2),
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
        duration: const Duration(seconds: 12),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _resend() async {
    final result = await PhoneAuthService.sendOtp(widget.phone);
    if (!mounted) return;
    if (result.success) {
      _startCountdown();
      if (result.simulatedCode != null) {
        setState(() => _code = result.simulatedCode);
        _showSmsBanner(result.simulatedCode!);
      }
    }
  }

  Future<void> _verify() async {
    final code = _otpKey.currentState?.value ?? '';
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await PhoneAuthService.verify(
      phone: widget.phone,
      code: code,
      verificationId: widget.verificationId,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.error ?? 'Verification failed.');
      _otpKey.currentState?.clear();
      return;
    }

    await SessionService.savePending(phone: widget.phone);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(role: widget.role),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final masked = widget.phone.length > 4
        ? '${widget.phone.substring(0, widget.phone.length - 4)}****'
        : widget.phone;

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
                'Verify your number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to $masked.',
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Change number',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              OtpBox(key: _otpKey, onCompleted: (_) => _verify()),

              const SizedBox(height: 24),

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
              if (_error != null) const SizedBox(height: 16),

              GradientButton(
                label: 'Verify & Continue',
                icon: Icons.check,
                loading: _loading,
                onPressed: _verify,
              ),

              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: _countdown > 0 ? null : _resend,
                  child: Text(
                    _countdown > 0
                        ? 'Resend in ${_countdown}s'
                        : 'Resend Code',
                    style: TextStyle(
                      color: _countdown > 0
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              if (widget.simulatedCode != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo mode: On Android you get real SMS. On Web the code is ${widget.simulatedCode}.',
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}