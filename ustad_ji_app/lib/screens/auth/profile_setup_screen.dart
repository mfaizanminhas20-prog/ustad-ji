import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'permissions_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String role;
  const ProfileSetupScreen({super.key, required this.role});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _skill = TextEditingController();
  String _city = 'Lahore';
  bool _loading = false;
  String? _error;

  static const _cities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta'
  ];

  static const _skills = [
    'AC Repair',
    'Plumbing',
    'Electrical',
    'Fan Repair',
    'Refrigerator Repair',
    'Washing Machine Repair',
    'Geyser Repair',
    'Carpentry'
  ];

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().length < 3) {
      setState(() => _error = 'Enter your full name.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final pending = await SessionService.loadPending();
    final phone = pending['phone'];
    final role = pending['role'] ?? widget.role;

    if (phone == null) {
      setState(() {
        _loading = false;
        _error = 'Session lost. Please start over.';
      });
      return;
    }

    final result = await AuthService.signupWithPhone(
      fullName: _name.text.trim(),
      phone: phone,
      role: role,
      skill: role == 'worker' ? _skill.text.trim() : null,
      city: _city,
    );

    if (!result.success) {
      setState(() {
        _loading = false;
        _error = result.error;
      });
      return;
    }

    // Save session so we can auto-login after permissions screen
    await SessionService.save(result.user!);
    await SessionService.savePending(
      name: _name.text.trim(),
      city: _city,
      skill: role == 'worker' ? _skill.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PermissionsScreen(role: role),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _skill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.role == 'worker';

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
                'Almost there',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isWorker
                    ? 'Tell customers who you are and what you do.'
                    : 'Tell us a bit about yourself.',
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),

              _label('Your name'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: _deco('e.g. Faizan Ahmed', Icons.person_outline),
              ),
              const SizedBox(height: 18),

              _label('City'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _city,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                    items: _cities
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (v) => setState(() => _city = v ?? 'Lahore'),
                  ),
                ),
              ),

              if (isWorker) ...[
                const SizedBox(height: 18),
                _label('Your primary skill'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _skill.text.isEmpty ? _skills.first : _skill.text,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary),
                      items: _skills
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _skill.text = v ?? ''),
                    ),
                  ),
                ),
              ],

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
              if (_error != null) const SizedBox(height: 14),

              GradientButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                loading: _loading,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
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