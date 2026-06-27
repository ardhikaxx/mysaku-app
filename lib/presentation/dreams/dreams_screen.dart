import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const FloatingCapsuleAppBar(
        title: AppStrings.dreamsTitle,
        leadingIcon: Icons.auto_awesome_rounded,
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
                if (list.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.auto_awesome_outlined,
                            size: 56, color: AppColors.divider),
                        SizedBox(height: 12),
                        Text('Belum ada impian / target',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 14)),
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
                    return DreamCard(dream: item, canEdit: canEdit);
                  },
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
          backgroundColor: AppColors.accentAmber,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
