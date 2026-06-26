import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';
import 'transaction_item_card.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';
    final wallet = ref.watch(walletProvider).value;
    final isOwner = wallet?.ownerId == currentUid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEF2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTab(ref, filter, 'all', 'Semua'),
                  _buildTab(ref, filter, 'income', 'Masuk'),
                  _buildTab(ref, filter, 'expense', 'Keluar'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        txAsync.when(
          data: (allList) {
            var list = allList;
            if (filter == 'income') {
              list = list.where((x) => x.isIncome).toList();
            }
            if (filter == 'expense') {
              list = list.where((x) => x.isExpense).toList();
            }

            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16)),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 48, color: AppColors.divider),
                    SizedBox(height: 8),
                    Text('Belum ada transaksi',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final item = list[i];
                final canEdit = isOwner || item.createdBy == currentUid;
                return TransactionItemCard(tx: item, canEdit: canEdit);
              },
            );
          },
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator())),
          error: (err, _) => Center(
              child: Text('Error: $err',
                  style: const TextStyle(color: Colors.red))),
        ),
      ],
    );
  }

  Widget _buildTab(
      WidgetRef ref, String currentFilter, String value, String label) {
    final isSelected = currentFilter == value;
    return GestureDetector(
      onTap: () => ref.read(transactionFilterProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
