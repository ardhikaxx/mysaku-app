import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/currency_extension.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import 'widgets/dream_card.dart';

class DreamsScreen extends ConsumerWidget {
  const DreamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreamsAsync = ref.watch(dreamsProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';
    final wallet = ref.watch(walletProvider).value;
    final isOwner = wallet?.ownerId == currentUid;
    final balance = ref.watch(walletBalanceProvider);
    final filter = ref.watch(dreamFilterProvider);
    final sort = ref.watch(dreamSortProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const FloatingCapsuleAppBar(
        title: AppStrings.dreamsTitle,
        leadingIcon: Icons.card_giftcard_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target impian yang ingin dicapai bersama dari total saldo tabungan saat ini.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            dreamsAsync.when(
              data: (list) {
                double totalTarget = 0;
                int achievedCount = 0;
                for (var d in list) {
                  totalTarget += d.targetAmount;
                  if (d.isAchieved || balance >= d.targetAmount) {
                    achievedCount++;
                  }
                }

                var filteredList = list.where((d) {
                  final isAch = d.isAchieved || balance >= d.targetAmount;
                  if (filter == 'active') return !isAch;
                  if (filter == 'achieved') return isAch;
                  return true;
                }).toList();

                filteredList.sort((a, b) {
                  if (sort == 'progress') {
                    final progA = a.calculateProgress(balance);
                    final progB = b.calculateProgress(balance);
                    return progB.compareTo(progA);
                  } else if (sort == 'amount_desc') {
                    return b.targetAmount.compareTo(a.targetAmount);
                  } else if (sort == 'amount_asc') {
                    return a.targetAmount.compareTo(b.targetAmount);
                  }
                  return 0; // default
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Ringkasan Akumulasi Impian
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.card_giftcard_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Target Akumulasi',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  totalTarget.toIDR,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Saldo dompet: ${balance.toIDR} • $achievedCount/${list.length} Tercapai',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Filter Tab & Sort Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                              _buildTab(ref, filter, 'active', 'Aktif'),
                              _buildTab(ref, filter, 'achieved', 'Tercapai'),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          initialValue: sort,
                          onSelected: (val) =>
                              ref.read(dreamSortProvider.notifier).state = val,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFF3F4F6), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sort_rounded,
                                    size: 18, color: AppColors.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  _getSortLabel(sort),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'default', child: Text('Terbaru')),
                            const PopupMenuItem(
                                value: 'progress',
                                child: Text('Progres Tertinggi')),
                            const PopupMenuItem(
                                value: 'amount_desc',
                                child: Text('Target Terbesar')),
                            const PopupMenuItem(
                                value: 'amount_asc',
                                child: Text('Target Terkecil')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (filteredList.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Column(
                          children: [
                            Icon(Icons.card_giftcard_outlined,
                                size: 56, color: AppColors.divider),
                            SizedBox(height: 12),
                            Text('Tidak ada impian pada kategori ini',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final item = filteredList[i];
                          final canEdit =
                              isOwner || item.createdBy == currentUid;
                          return DreamCard(dream: item, canEdit: canEdit);
                        },
                      ),
                  ],
                );
              },
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator())),
              error: (err, _) => Center(
                  child: Text('Error: $err',
                      style: const TextStyle(color: Colors.red))),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push('/home/dreams/add'),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'progress':
        return 'Progres';
      case 'amount_desc':
        return 'Terbesar';
      case 'amount_asc':
        return 'Terkecil';
      default:
        return 'Terbaru';
    }
  }

  Widget _buildTab(
      WidgetRef ref, String currentFilter, String value, String label) {
    final isSelected = currentFilter == value;
    return GestureDetector(
      onTap: () => ref.read(dreamFilterProvider.notifier).state = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
