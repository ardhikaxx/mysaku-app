import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../providers/transaction_provider.dart';

class AnalyticsCard extends ConsumerWidget {
  const AnalyticsCard({super.key});

  final List<Color> _palette = const [
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFF64748B), // Slate
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txList = ref.watch(transactionsProvider).value ?? [];
    final now = DateTime.now();

    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (final tx in txList) {
      if (tx.isExpense &&
          tx.transactionDate.year == now.year &&
          tx.transactionDate.month == now.month) {
        final cat = tx.category.isNotEmpty ? tx.category : 'Lainnya';
        categoryTotals[cat] = (categoryTotals[cat] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Statistik Pengeluaran Bulan Ini',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalExpense == 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 40, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada pengeluaran bulan ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Stacked Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final catEntry = entry.value;
                    final ratio = (catEntry.value / totalExpense);
                    final color = _palette[index % _palette.length];
                    return Flexible(
                      flex: (ratio * 1000).toInt() + 1,
                      child: Container(
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category list breakdown
            Column(
              children: sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final catEntry = entry.value;
                final ratio = (catEntry.value / totalExpense);
                final color = _palette[index % _palette.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            catEntry.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            catEntry.value.toIDR,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 42,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${(ratio * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
