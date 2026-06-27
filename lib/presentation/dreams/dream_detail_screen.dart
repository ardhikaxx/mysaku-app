import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../data/models/dream_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';

class DreamDetailScreen extends ConsumerWidget {
  final DreamModel dream;

  const DreamDetailScreen({super.key, required this.dream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.watch(authStateProvider).value?.uid;
    final walletAsync = ref.watch(walletProvider);
    final isOwner = walletAsync.value?.ownerId == currentUid;
    final canEdit = isOwner || dream.createdBy == currentUid;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Detail Impian',
        showBack: true,
        onLeadingTap: () => context.pop(),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                tooltip: 'Edit Impian',
                onPressed: () => context.push('/home/dreams/edit/${dream.dreamId}',
                    extra: dream),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: dream.isAchieved
                        ? AppColors.accentGreen
                        : const Color(0xFFF3F4F6),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Color(0xFFD97706), size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dream.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: dream.isAchieved
                          ? AppColors.accentGreen.withOpacity(0.15)
                          : const Color(0xFFFEF3C7).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dream.isAchieved ? 'Tercapai' : 'Sedang Dikerjakan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dream.isAchieved
                            ? AppColors.accentGreen
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Target: ${dream.targetAmount.toIDR}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Dibuat',
                      '${dream.createdAt.toFullDate}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(
                      Icons.access_time_outlined, 'Terakhir Diubah',
                      '${dream.updatedAt.toFullDate}'),
                ],
              ),
            ),
            if (canEdit) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFEF4444)),
                  label: const Text('Hapus Impian',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w600,
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
      message: 'Impian keuangan ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
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