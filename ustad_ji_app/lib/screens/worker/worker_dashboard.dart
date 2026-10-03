import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/job_tile.dart';
import '../../widgets/stat_tile.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  bool _autoPilot = true;
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            _buildJobs(),
            const _DarkPlaceholder(
                label: 'Earnings', icon: Icons.bar_chart),
            const _DarkPlaceholder(
                label: 'Profile', icon: Icons.person),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.darkSurface,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                _navItem(0, Icons.work_outline, Icons.work, 'Jobs'),
                _navItem(1, Icons.bar_chart_outlined, Icons.bar_chart,
                    'Earnings'),
                _navItem(2, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData active, String label) {
    final selected = _navIndex == idx;
    final color = selected ? AppColors.primaryLight : AppColors.darkTextDim;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _navIndex = idx),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? active : icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobs() {
    final user = appState.user;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: const Icon(Icons.engineering,
                    color: AppColors.primaryLight, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Ali AC Services',
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verified Ustad - ${user?.city ?? "Lahore"}',
                      style: const TextStyle(
                        color: AppColors.darkTextDim,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.accent, size: 15),
                    SizedBox(width: 5),
                    Text(
                      '4.8',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              Expanded(
                child: StatTile(
                  label: 'Earnings Today',
                  value: 'Rs 3,250',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryLight,
                  dark: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Bids Placed',
                  value: '4',
                  icon: Icons.bolt,
                  color: AppColors.accent,
                  dark: true,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.darkCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _autoPilot
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.darkBorder,
                width: _autoPilot ? 1.4 : 1,
              ),
              boxShadow: _autoPilot
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _autoPilot
                        ? AppColors.primary.withOpacity(0.18)
                        : AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _autoPilot ? Icons.bolt : Icons.power_settings_new,
                    color: _autoPilot
                        ? AppColors.primaryLight
                        : AppColors.darkTextDim,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Auto-Pilot',
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _autoPilot
                            ? 'AI agent is bidding on matching jobs'
                            : 'Manual mode - bid yourself',
                        style: const TextStyle(
                          color: AppColors.darkTextDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _autoPilot,
                  activeColor: AppColors.primaryLight,
                  activeTrackColor: AppColors.primary.withOpacity(0.4),
                  onChanged: (v) => setState(() => _autoPilot = v),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Incoming Jobs',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${MockData.workerFeed.length} live',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            itemCount: MockData.workerFeed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => JobTile(
              job: MockData.workerFeed[i],
              autoPilot: _autoPilot,
              onBid: () {},
            )
                .animate()
                .fadeIn(delay: (350 + i * 80).ms)
                .slideX(begin: 0.15, curve: Curves.easeOutCubic),
          ),
        ),
      ],
    );
  }
}

class _DarkPlaceholder extends StatelessWidget {
  final String label;
  final IconData icon;
  const _DarkPlaceholder({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 56,
              color: AppColors.darkTextDim.withOpacity(0.5)),
          const SizedBox(height: 14),
          Text(
            '$label coming soon',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.darkTextDim,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}