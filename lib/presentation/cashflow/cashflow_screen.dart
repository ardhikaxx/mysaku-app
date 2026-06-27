import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/transaction_list.dart';

class CashflowScreen extends ConsumerWidget {
  const CashflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txList = ref.watch(transactionsProvider).value ?? [];
    double income = 0;
    double expense = 0;
    for (final tx in txList) {
      if (tx.isIncome) income += tx.amount;
      if (tx.isExpense) expense += tx.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: AppStrings.appName,
        trailing: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF111827), size: 20),
            onPressed: () {},
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            const BalanceCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                SummaryCard(
                  title: AppStrings.totalIncome,
                  amount: income.toCompactIDR,
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                SummaryCard(
                  title: AppStrings.totalExpense,
                  amount: expense.toCompactIDR,
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const TransactionList(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push('/home/cashflow/add'),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
