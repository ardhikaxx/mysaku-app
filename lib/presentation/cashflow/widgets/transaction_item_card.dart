import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/user_provider.dart';

class TransactionItemCard extends ConsumerWidget {
  final TransactionModel tx;
  final bool canEdit;

  const TransactionItemCard({
    super.key,
    required this.tx,
    required this.canEdit,
  });

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

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/home/cashflow/detail/${tx.transactionId}',
              extra: tx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getCategoryIcon(tx.category),
                      color: const Color(0xFF4B5563), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.description?.isNotEmpty == true
                            ? '${tx.description} • ${tx.transactionDate.toShortDate}'
                            : '${tx.createdByName} • ${tx.transactionDate.toShortDate}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$prefix${tx.amount.toIDR}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!canEdit) return cardContent;

    return Dismissible(
      key: Key(tx.transactionId),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(20),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
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
          context.push('/home/cashflow/edit/${tx.transactionId}', extra: tx);
          return false;
        } else {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Hapus Transaksi?'),
              content: Text('Transaksi "${tx.name}" akan dihapus permanen.'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(false),
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () => ctx.pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hapus'),
                ),
              ],
            ),
          );

          if (confirmed != true) return false;

          final walletId = ref.read(activeWalletIdProvider);
          if (walletId == null) return false;

          try {
            final repo = ref.read(transactionRepositoryProvider);
            await repo.deleteTransaction(walletId, tx.transactionId);
            return true;
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')));
            }
            return false;
          }
        }
      },
      child: cardContent,
    );
  }
}
