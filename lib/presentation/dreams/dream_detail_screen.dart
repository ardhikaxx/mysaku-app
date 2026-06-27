import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../data/models/dream_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';

class DreamDetailScreen extends ConsumerWidget {
  final DreamModel dream;

  const DreamDetailScreen({
    super.key,
    required this.dream,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(walletBalanceProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';
    final wallet = ref.watch(walletProvider).value;
    final isOwner = wallet?.ownerId == currentUid;
    final canEdit = isOwner || dream.createdBy == currentUid;

    final progress = dream.calculateProgress(balance);
    final isAchieved = dream.isAchieved || balance >= dream.targetAmount;
    final remaining = (dream.targetAmount - balance).clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Detail Impian',
        showBack: true,
        onLeadingTap: () => context.pop(),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
                onPressed: () =>
                    context.push('/home/dreams/edit/${dream.dreamId}',
                        extra: dream),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO PROGRESS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAchieved
                      ? [const Color(0xFF064E3B), const Color(0xFF047857)]
                      : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: (isAchieved
                            ? const Color(0xFF047857)
                            : const Color(0xFF0F172A))
                        .withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isAchieved
                          ? Icons.emoji_events_rounded
                          : Icons.auto_awesome_rounded,
                      color: isAchieved
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFBBF24),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    dream.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (dream.description != null &&
                      dream.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      dream.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAchieved
                          ? '🎉 Impian Telah Tercapai!'
                          : 'Progres Saat Ini: ${progress.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isAchieved
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAchieved
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terkumpul',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            balance >= dream.targetAmount
                                ? dream.targetAmount.toIDR
                                : balance.toIDR,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Target Dana',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dream.targetAmount.toIDR,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isAchieved) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.accentAmber, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Dibutuhkan tambahan dana sebesar ${remaining.toIDR} lagi di saldo dompet untuk mewujudkan impian ini!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // GROUPED INFO CARD
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'INFORMASI TARGET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.6),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                      Icons.calendar_today_outlined, 'Dibuat Pada', '${dream.createdAt.toFullDate}'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                        height: 1,
                        color: AppColors.divider.withValues(alpha: 0.4)),
                  ),
                  _buildDetailRow(
                      Icons.update_rounded, 'Terakhir Diperbarui', '${dream.updatedAt.toFullDate}'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(
                        height: 1,
                        color: AppColors.divider.withValues(alpha: 0.4)),
                  ),
                  _buildDetailRow(
                      Icons.verified_outlined,
                      'Status Pencapaian',
                      isAchieved ? 'Tercapai 100%' : 'Sedang Menabung'),
                ],
              ),
            ),
            if (canEdit) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444)),
                  label: const Text(
                    'Hapus Impian Ini',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFFFECACA), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Impian?',
      message:
          'Impian keuangan ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFFEF4444),
    );

    if (confirmed != true) return;

    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    try {
      final repo = ref.read(dreamRepositoryProvider);
      await repo.deleteDream(walletId, dream.dreamId);
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }
}