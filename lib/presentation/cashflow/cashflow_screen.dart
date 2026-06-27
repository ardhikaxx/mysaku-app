import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/analytics_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/budget_card.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 6),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Kiri: Avatar + Nama + Email
                  GestureDetector(
                    onTap: () => context.go('/home/profile'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 19,
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
                                  fontSize: 15,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nama + Email
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/home/profile'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Pengguna',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: -0.3,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10.5,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Kanan: Ikon + MySaku
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF1E88E5)],
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: -0.4,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: BalanceCard(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
                  const BudgetCard(),
                  const SizedBox(height: 16),
                  const AnalyticsCard(),
                  const SizedBox(height: 24),
                  const TransactionList(),
                ],
              ),
            ),
          ),
        ],
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
