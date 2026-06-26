import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../data/models/dream_model.dart';
import '../../../providers/transaction_provider.dart';
import 'dream_progress_bar.dart';

class DreamCard extends ConsumerWidget {
  final DreamModel dream;
  final bool canEdit;

  const DreamCard({
    super.key,
    required this.dream,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final progress = dream.calculateProgress(balance);
    final isAchieved = dream.isAchieved || balance >= dream.targetAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isAchieved ? AppColors.accentGreen : AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: canEdit
            ? () => context.push('/home/dreams/edit/${dream.dreamId}',
                extra: dream)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dream.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ),
                if (isAchieved)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.accentGreen, size: 14),
                        SizedBox(width: 4),
                        Text('Tercapai',
                            style: TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            if (dream.description != null && dream.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(dream.description!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Target Terkumpul',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  dream.targetAmount.toIDR,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DreamProgressBar(percentage: progress),
          ],
        ),
      ),
    );
  }
}
