import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';
import 'transaction_item_card.dart';

class TransactionList extends ConsumerStatefulWidget {
  const TransactionList({super.key});

  @override
  ConsumerState<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsProvider);
    final filter = ref.watch(transactionFilterProvider);
    final searchQuery = ref.watch(transactionSearchProvider);
    final monthFilter = ref.watch(transactionMonthFilterProvider);
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
        // Filter Bulan Selector
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        final current = monthFilter ?? DateTime.now();
                        var year = current.year;
                        var month = current.month - 1;
                        if (month < 1) {
                          month = 12;
                          year -= 1;
                        }
                        ref.read(transactionMonthFilterProvider.notifier).state =
                            DateTime(year, month);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left_rounded, size: 22, color: Color(0xFF6B7280)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (monthFilter == null) {
                          ref.read(transactionMonthFilterProvider.notifier).state =
                              DateTime(DateTime.now().year, DateTime.now().month);
                        } else {
                          ref.read(transactionMonthFilterProvider.notifier).state = null;
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            monthFilter == null ? Icons.calendar_today_outlined : Icons.calendar_month_rounded,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            monthFilter == null
                                ? 'Semua Bulan'
                                : _getMonthYearLabel(monthFilter),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final current = monthFilter ?? DateTime.now();
                        var year = current.year;
                        var month = current.month + 1;
                        if (month > 12) {
                          month = 1;
                          year += 1;
                        }
                        ref.read(transactionMonthFilterProvider.notifier).state =
                            DateTime(year, month);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                if (monthFilter == null) {
                  ref.read(transactionMonthFilterProvider.notifier).state =
                      DateTime(DateTime.now().year, DateTime.now().month);
                } else {
                  ref.read(transactionMonthFilterProvider.notifier).state = null;
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: monthFilter == null ? const Color(0xFFEFF6FF) : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  monthFilter == null ? 'Bulan Ini' : 'Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: monthFilter == null ? AppColors.primaryColor : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              ref.read(transactionSearchProvider.notifier).state = val;
            },
            decoration: InputDecoration(
              hintText: 'Cari transaksi...',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6B7280), size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Color(0xFF6B7280)),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(transactionSearchProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
          ),
        ),
        const SizedBox(height: 14),
        txAsync.when(
          data: (allList) {
            var list = allList;
            if (filter == 'income') {
              list = list.where((x) => x.isIncome).toList();
            }
            if (filter == 'expense') {
              list = list.where((x) => x.isExpense).toList();
            }

            if (monthFilter != null) {
              list = list.where((tx) {
                return tx.transactionDate.year == monthFilter.year &&
                       tx.transactionDate.month == monthFilter.month;
              }).toList();
            }

            final query = searchQuery.toLowerCase().trim();
            if (query.isNotEmpty) {
              list = list.where((tx) {
                final nameMatches = tx.name.toLowerCase().contains(query);
                final descMatches = tx.description?.toLowerCase().contains(query) ?? false;
                final amountMatches = tx.amount.toString().contains(query);
                final categoryMatches = tx.category.toLowerCase().contains(query);
                return nameMatches || descMatches || amountMatches || categoryMatches;
              }).toList();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Ringkasan Total Nominal Hasil Filter
                if (list.isNotEmpty || query.isNotEmpty || monthFilter != null || filter != 'all') ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: filter == 'expense'
                          ? const Color(0xFFFEF2F2)
                          : filter == 'income'
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: filter == 'expense'
                            ? const Color(0xFFFECACA)
                            : filter == 'income'
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          filter == 'expense'
                              ? Icons.arrow_upward_rounded
                              : filter == 'income'
                                  ? Icons.arrow_downward_rounded
                                  : Icons.analytics_outlined,
                          size: 18,
                          color: filter == 'expense'
                              ? const Color(0xFFDC2626)
                              : filter == 'income'
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getSummaryText(list, filter),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: filter == 'expense'
                                  ? const Color(0xFF991B1B)
                                  : filter == 'income'
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (list.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Icon(
                          query.isNotEmpty || monthFilter != null
                              ? Icons.search_off_rounded
                              : Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.divider,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          query.isNotEmpty || monthFilter != null
                              ? 'Transaksi tidak ditemukan'
                              : 'Belum ada transaksi',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final item = list[i];
                      final canEdit = isOwner || item.createdBy == currentUid;
                      return TransactionItemCard(tx: item, canEdit: canEdit);
                    },
                  ),
              ],
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

  String _getMonthYearLabel(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _getSummaryText(List<TransactionModel> list, String filter) {
    double inc = 0;
    double exp = 0;
    for (var t in list) {
      if (t.isIncome) inc += t.amount;
      if (t.isExpense) exp += t.amount;
    }

    if (filter == 'expense') {
      return 'Ditemukan ${list.length} transaksi • Total Keluar: ${exp.toIDR}';
    } else if (filter == 'income') {
      return 'Ditemukan ${list.length} transaksi • Total Masuk: ${inc.toIDR}';
    } else {
      return 'Ditemukan ${list.length} transaksi • Masuk: ${inc.toCompactIDR} • Keluar: ${exp.toCompactIDR}';
    }
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
                    color: Colors.black.withValues(alpha: 0.06),
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
