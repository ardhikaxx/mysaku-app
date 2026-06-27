import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/transaction_list.dart';

class CashflowScreen extends ConsumerWidget {
  const CashflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txList = ref.watch(transactionsProvider).value ?? [];
    final user = ref.watch(userProvider).value;
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
        trailing: GestureDetector(
          onTap: () => context.go('/home/profile'),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEFF6FF),
              backgroundImage: user != null && user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user == null || user.photoUrl == null
                  ? Text(
                      user != null && user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
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
