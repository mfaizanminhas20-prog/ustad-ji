import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mock_data.dart';
import '../../models/job_response.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_thinking_trace.dart';
import '../../widgets/estimate_card.dart';
import '../../widgets/gradient_button.dart';
import 'job_tracking_screen.dart';

class PostJobScreen extends StatefulWidget {
  final String? initialText;
  const PostJobScreen({super.key, this.initialText});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  late final TextEditingController _controller;
  bool _loading = false;
  JobResponse? _result;
  String? _error;
  List<String> _traceLines = [];
  bool _traceComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _findUstad());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _findUstad() async {
    FocusScope.of(context).unfocus();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please describe your problem.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _traceLines = [];
      _traceComplete = false;
    });

    final lower = text.toLowerCase();
    String category = 'General Service';
    int price = 1000;
    if (lower.contains('ac') && (lower.contains('leak') || lower.contains('water'))) {
      category = 'AC Repair'; price = 1500;
    } else if (lower.contains('ac') || lower.contains('air conditioner')) {
      category = 'AC Repair'; price = 2000;
    } else if (lower.contains('pipe') || lower.contains('tap')) {
      category = 'Plumbing'; price = 800;
    } else if (lower.contains('short') || lower.contains('wire') || lower.contains('electric')) {
      category = 'Electrical'; price = 1200;
    } else if (lower.contains('fan')) {
      category = 'Fan Repair'; price = 600;
    } else if (lower.contains('fridge') || lower.contains('refrigerator')) {
      category = 'Refrigerator Repair'; price = 2500;
    } else if (lower.contains('washing') || lower.contains('washer')) {
      category = 'Washing Machine Repair'; price = 1800;
    } else if (lower.contains('geyser') || lower.contains('heater')) {
      category = 'Geyser Repair'; price = 2000;
    } else if (lower.contains('lock') || lower.contains('door')) {
      category = 'Carpentry'; price = 700;
    }

    final bid1 = (price * 0.92).round();
    final bid2 = (price * 0.95).round();
    final bid3 = (price * 0.97).round();
    final winner = [bid1, bid2, bid3].reduce((a, b) => a < b ? a : b);

    final steps = [
      '> Parsing problem: "$text"',
      'V Intent classified: $category',
      '> Querying RAG knowledge base (127 entries)...',
      'V Matched 3 keywords -> baseline Rs $price',
      '> Dispatching AI agents to 3 nearby ustads...',
      'V Hassan Cooling bid: Rs $bid1',
      'V Ali AC Services bid: Rs $bid2',
      'V Ustad Bilal bid: Rs $bid3',
      '> Ranking by price x rating x distance...',
      'V Winner selected: Rs $winner',
    ];

    for (var i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() => _traceLines = [..._traceLines, steps[i]]);
    }

    try {
      final data = await ApiService.postJob(text);
      if (!mounted) return;
      setState(() {
        _result = data;
        _traceComplete = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Post a Job',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tell us what's wrong",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 6),
              const Text(
                'Our AI will match you with the right ustad and estimate the price.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. My AC is leaking water in the bedroom...',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.5,
                        ),
                        filled: true,
                        fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GradientButton(
                      label: 'Get AI Estimate',
                      icon: Icons.auto_awesome,
                      loading: _loading,
                      onPressed: _findUstad,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
              const SizedBox(height: 20),
              const Text(
                'Quick examples',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockData.popularSearches.map((q) {
                  return GestureDetector(
                    onTap: () {
                      _controller.text = q;
                      _findUstad();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        q,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.danger.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().shakeX(),
              if (_traceLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AiThinkingTrace(
                    lines: _traceLines,
                    complete: _traceComplete,
                  ),
                ),
              if (_result != null)
                EstimateCard(
                  result: _result!,
                  onConfirm: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobTrackingScreen(result: _result!),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}