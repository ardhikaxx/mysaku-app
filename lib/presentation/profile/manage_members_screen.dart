import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'widgets/member_item_card.dart';

class ManageMembersScreen extends ConsumerWidget {
  const ManageMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final currentUid = ref.watch(authStateProvider).value?.uid ?? '';
    final wallet = ref.watch(walletProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: AppStrings.manageMembers,
        showBack: true,
        onLeadingTap: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola anggota yang memiliki akses ke tabungan bersama ini.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            membersAsync.when(
              data: (list) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final m = list[i];
                  final isMe = m.uid == currentUid;
                  return MemberItemCard(
                    member: m,
                    isCurrentUser: isMe,
                    onRemove: (!m.isOwner && wallet != null)
                      ? () async {
                          final confirm = await ConfirmDialog.show(
                            context,
                            title: 'Hapus Anggota?',
                            message: 'Akses ${m.name} ke tabungan ini akan dicabut.',
                            confirmText: 'Hapus',
                            icon: Icons.person_remove_outlined,
                            iconColor: const Color(0xFFEF4444),
                          );

                          if (confirm == true) {
                            final userRepo = ref.read(userRepositoryProvider);
                            final userDoc = await userRepo.getUser(m.uid);
                            final personalW =
                                userDoc?.personalWalletId ?? m.uid;
                            ref.read(walletRepositoryProvider).leaveWallet(
                                wallet.walletId, m.uid, personalW);
                          }
                        }
                      : null,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
