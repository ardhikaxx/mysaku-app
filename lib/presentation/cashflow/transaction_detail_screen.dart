import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/currency_extension.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/app_toast.dart';
import '../../core/utils/app_undo_toast.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel tx;

  const TransactionDetailScreen({super.key, required this.tx});

  String _getCategoryLabel(String cat) {
    const map = {
      'salary': 'Gaji',
      'freelance': 'Freelance',
      'investment': 'Investasi',
      'bonus': 'Bonus',
      'gift': 'Hadiah / Pemberian',
      'other_income': 'Pemasukan Lainnya',
      'food': 'Makan & Minum',
      'transport': 'Transportasi',
      'bills': 'Tagihan',
      'shopping': 'Belanja',
      'health': 'Kesehatan',
      'education': 'Pendidikan',
      'entertainment': 'Hiburan',
      'savings': 'Tabungan / Investasi',
      'other_expense': 'Pengeluaran Lainnya',
    };
    return map[cat] ?? cat;
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'salary':
        return Icons.payments_outlined;
      case 'freelance':
        return Icons.work_outline;
      case 'investment':
        return Icons.trending_up;
      case 'bonus':
        return Icons.card_giftcard;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'bills':
        return Icons.receipt_long_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'savings':
        return Icons.savings_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color =
        tx.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final prefix = tx.isIncome ? '+ ' : '- ';

    final currentUid = ref.watch(authStateProvider).value?.uid;
    final walletAsync = ref.watch(walletProvider);
    final isOwner = walletAsync.value?.ownerId == currentUid;
    final canEdit = isOwner || tx.createdBy == currentUid;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Detail Transaksi',
        showBack: true,
        onLeadingTap: () => context.pop(),
        trailing: canEdit
            ? IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.textPrimary),
                tooltip: 'Edit Transaksi',
                onPressed: () {
                  final path = GoRouterState.of(context).uri.path;
                  final base = path.startsWith('/home/history')
                      ? '/home/history'
                      : '/home/cashflow';
                  context.push('$base/edit/${tx.transactionId}', extra: tx);
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          children: [
            // Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
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
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getCategoryIcon(tx.category),
                        color: color, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tx.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getCategoryLabel(tx.category),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$prefix${tx.amount.toIDR}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metadata Cards
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal',
                      '${tx.transactionDate.toFullDate} • ${tx.transactionDate.toTime}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(
                      Icons.person_outline, 'Dicatat Oleh', tx.createdByName),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  _buildDetailRow(Icons.swap_vert, 'Tipe Transaksi',
                      tx.isIncome ? 'Pemasukan' : 'Pengeluaran'),
                  if (tx.description != null &&
                      tx.description!.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                    ),
                    _buildDetailRow(Icons.notes, 'Catatan', tx.description!),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (canEdit)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_outline,
                      color: Color(0xFFEF4444)),
                  label: const Text('Hapus Transaksi',
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
      title: 'Hapus Transaksi?',
      message: 'Transaksi ini akan dihapus secara permanen dari tabungan.',
      confirmText: 'Hapus',
    );

    if (confirmed != true || !context.mounted) return;

    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final oldTx = tx;
      await repo.deleteTransaction(walletId, tx.transactionId);
      AppHaptics.successFeedback();
      if (context.mounted) {
        final currentContext = context;
        currentContext.pop();
        AppUndoToast.show(
          currentContext,
          message: 'Data transaksi berhasil dihapus',
          onUndo: () async {
            await repo.addTransaction(walletId, oldTx);
            if (currentContext.mounted) {
              AppToast.showSuccess(currentContext, 'Penghapusan dibatalkan (data dipulihkan)');
            }
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, 'Gagal menghapus data: Terjadi kesalahan sistem');
      }
    }
  }
}
