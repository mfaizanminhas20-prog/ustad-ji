import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class JobTile extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool autoPilot;
  final VoidCallback? onBid;

  const JobTile({
    super.key,
    required this.job,
    required this.autoPilot,
    this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job['title'] ?? '',
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                'Rs ${job['price']}',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _chip(job['category'] ?? ''),
              const SizedBox(width: 8),
              _iconText(Icons.location_on_outlined, job['area'] ?? ''),
              const Spacer(),
              _iconText(Icons.near_me_outlined, job['distance'] ?? ''),
            ],
          ),
          if (job['posted'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Posted ${job['posted']}',
              style: const TextStyle(
                color: AppColors.darkTextDim,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkBorder),
                    foregroundColor: AppColors.darkText,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.green,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onBid,
                    icon: const Icon(Icons.bolt, size: 18, color: Colors.black),
                    label: Text(
                      autoPilot ? 'Auto-Bid' : 'Place Bid',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.darkTextDim),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.darkTextDim, fontSize: 12),
        ),
      ],
    );
  }
}
