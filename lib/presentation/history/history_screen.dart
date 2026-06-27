import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../cashflow/widgets/transaction_list.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const FloatingCapsuleAppBar(
        title: 'Riwayat Transaksi',
        leadingIcon: Icons.receipt_long_rounded,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seluruh catatan arus kas masuk dan keluar yang tercatat dalam dompet Anda.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 16),
            TransactionList(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => context.push('/home/history/add'),
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
