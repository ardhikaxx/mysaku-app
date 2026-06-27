import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/privacy_provider.dart';
import '../../../providers/transaction_provider.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txList = ref.watch(transactionsProvider).value ?? [];
    final budget = ref.watch(monthlyBudgetProvider);
    final isHidden = ref.watch(privacyProvider);

    final now = DateTime.now();
    double currentMonthExpense = 0;
    for (final tx in txList) {
      if (tx.isExpense &&
          tx.transactionDate.year == now.year &&
          tx.transactionDate.month == now.month) {
        currentMonthExpense += tx.amount;
      }
    }

    final double ratio = budget > 0 ? (currentMonthExpense / budget) : 0.0;
    final double clampedRatio = ratio.clamp(0.0, 1.0);

    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int remainingDays = (daysInMonth - now.day + 1).clamp(1, 31);
    final double remainingBudget = budget - currentMonthExpense;
    final double dailyBurnRate =
        remainingBudget > 0 ? (remainingBudget / remainingDays) : 0.0;

    Color statusColor;
    String statusText;
    if (ratio >= 1.0) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Melebihi Anggaran!';
    } else if (ratio >= 0.75) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Mendekati Batas';
    } else {
      statusColor = const Color(0xFF10B981);
      statusText = 'Anggaran Aman';
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.track_changes_rounded,
                        color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Anggaran Bulan Ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditBudgetDialog(context, ref, budget),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.primaryColor),
                      SizedBox(width: 4),
                      Text(
                        'Atur',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isHidden ? 'Rp ••••••' : currentMonthExpense.toIDR,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                isHidden ? 'dari Rp •••••' : 'dari ${budget.toCompactIDR}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: clampedRatio,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}% terpakai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: remainingBudget <= 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: remainingBudget <= 0
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  remainingBudget <= 0
                      ? Icons.warning_amber_rounded
                      : Icons.insights_rounded,
                  size: 18,
                  color: remainingBudget <= 0
                      ? const Color(0xFFEF4444)
                      : AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF334155),
                      ),
                      children: remainingBudget <= 0
                          ? [
                              const TextSpan(
                                text:
                                    'Anggaran habis! Tekan rem pengeluaran Anda hari ini.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEF4444)),
                              ),
                            ]
                          : [
                              const TextSpan(text: 'Batas aman hari ini: '),
                              TextSpan(
                                text: isHidden ? 'Rp •••/hari' : '${dailyBurnRate.toIDR}/hari',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(
                                text: ' ($remainingDays hari lagi)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, WidgetRef ref, double currentBudget) {
    final controller = TextEditingController(
      text: NumberFormat.decimalPattern('id_ID').format(currentBudget.toInt()),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              void updateController(double amount) {
                final formatted =
                    NumberFormat.decimalPattern('id_ID').format(amount.toInt());
                controller.text = formatted;
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: formatted.length),
                );
                setStateDialog(() {});
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: const Color(0xFFDBEAFE), width: 2),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Atur Batas Anggaran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tentukan batas maksimal pengeluaran bulanan Anda untuk pengingat dan kontrol finansial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // TextField Box
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsFormatter(),
                      ],
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: AppColors.primaryColor,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilihan Cepat:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quick Suggestion Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickPill('2 Juta', 2000000, updateController),
                        _buildQuickPill('3 Juta', 3000000, updateController),
                        _buildQuickPill('5 Juta', 5000000, updateController),
                        _buildQuickPill('10 Juta', 10000000, updateController),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              onPressed: () {
                                AppHaptics.successFeedback();
                                final cleanText =
                                    controller.text.replaceAll('.', '');
                                final newBudget =
                                    double.tryParse(cleanText) ?? 3000000.0;
                                ref.read(monthlyBudgetProvider.notifier).state =
                                    newBudget;
                                Navigator.pop(ctx);
                              },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 4,
                              shadowColor: AppColors.primaryColor
                                  .withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickPill(String label, double amount, Function(double) onTap) {
    return InkWell(
      onTap: () {
        AppHaptics.lightTap();
        onTap(amount);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
