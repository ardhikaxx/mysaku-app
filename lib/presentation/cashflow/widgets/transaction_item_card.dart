import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/extensions/datetime_extension.dart';
import '../../../data/models/transaction_model.dart';

class TransactionItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = tx.isIncome ? AppColors.accentGreen : AppColors.accentRed;
    final prefix = tx.isIncome ? '+ ' : '- ';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: ListTile(
            onTap: canEdit
                ? () => context.push('/home/cashflow/edit/${tx.transactionId}',
                    extra: tx)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child:
                  Icon(_getCategoryIcon(tx.category), color: color, size: 20),
            ),
            title: Text(tx.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tx.description != null && tx.description!.isNotEmpty)
                  Text(tx.description!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  'Oleh ${tx.createdByName} • ${tx.transactionDate.toShortDate}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            trailing: Text(
              '$prefix${tx.amount.toIDR}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
