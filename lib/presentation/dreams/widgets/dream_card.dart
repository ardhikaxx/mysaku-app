import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../data/models/dream_model.dart';
import '../../../providers/dream_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/user_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';

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

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAchieved
              ? AppColors.accentGreen.withValues(alpha: 0.5)
              : AppColors.divider.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAchieved
                ? AppColors.accentGreen.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/home/dreams/detail/${dream.dreamId}',
              extra: dream),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAchieved
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isAchieved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6))
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isAchieved
                            ? Icons.emoji_events_rounded
                            : Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dream.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (dream.description != null &&
                              dream.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              dream.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAchieved
                            ? AppColors.accentGreen.withValues(alpha: 0.12)
                            : AppColors.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAchieved ? 'Tercapai' : '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: isAchieved
                              ? AppColors.accentGreen
                              : AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAchieved ? AppColors.accentGreen : AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terkumpul: ${balance >= dream.targetAmount ? dream.targetAmount.toIDR : balance.toIDR}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Target: ${dream.targetAmount.toIDR}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isAchieved
                            ? AppColors.accentGreen
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!canEdit) return cardContent;

    return Dismissible(
      key: Key(dream.dreamId),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text('Edit',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Hapus',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            SizedBox(width: 10),
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          context.push('/home/dreams/edit/${dream.dreamId}', extra: dream);
          return false;
        } else {
          final confirmed = await ConfirmDialog.show(
            context,
            title: 'Hapus Impian?',
            message:
                'Impian keuangan ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
            confirmText: 'Ya, Hapus',
            icon: Icons.delete_forever_rounded,
            iconColor: const Color(0xFFEF4444),
          );

          if (confirmed != true) return false;

          final walletId = ref.read(activeWalletIdProvider);
          if (walletId == null) return false;

          try {
            final repo = ref.read(dreamRepositoryProvider);
            await repo.deleteDream(walletId, dream.dreamId);
            return true;
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
            }
            return false;
          }
        }
      },
      child: cardContent,
    );
  }
}