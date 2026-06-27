import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../providers/transaction_provider.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E88E5)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textPrimary, size: 22),
              onPressed: () {},
            ),
          ),
        ],
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
