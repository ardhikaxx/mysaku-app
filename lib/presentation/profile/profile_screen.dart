import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showInvitationsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final invList = ref.watch(userInvitationsProvider).value ?? [];
          final currentUid = ref.watch(authStateProvider).value?.uid ?? '';

          if (invList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_outline, size: 48, color: AppColors.divider),
                  SizedBox(height: 12),
                  Text('Tidak ada undangan tertunda',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Undangan Bergabung',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: invList.length,
                    itemBuilder: (context, i) {
                      final inv = invList[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${inv.ownerName} mengundang Anda ke tabungan bersama "${inv.walletName}"',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(invitationRepositoryProvider)
                                        .respondInvitation(inv.invitationId,
                                            false, currentUid);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Tolak',
                                      style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(invitationRepositoryProvider)
                                        .respondInvitation(inv.invitationId,
                                            true, currentUid);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor),
                                  child: const Text('Terima & Switch',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final wallet = ref.watch(walletProvider).value;
    final invList = ref.watch(userInvitationsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }
          final isOwner = wallet?.ownerId == user.uid;
          final isPersonal = user.activeWalletId == user.personalWalletId;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 24),
                if (invList.isNotEmpty)
                  SettingsTile(
                    icon: Icons.mark_email_unread_outlined,
                    iconColor: AppColors.accentAmber,
                    title: 'Undangan Bergabung',
                    subtitle: '${invList.length} undangan menunggu respon',
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text('${invList.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    onTap: () => _showInvitationsModal(context, ref),
                  ),
                if (isOwner) ...[
                  SettingsTile(
                    icon: Icons.person_add_outlined,
                    title: AppStrings.inviteMember,
                    subtitle: 'Ajak keluarga atau pasangan (maks. 5 orang)',
                    onTap: () => context.push('/home/profile/invite'),
                  ),
                  SettingsTile(
                    icon: Icons.people_outline,
                    title: AppStrings.manageMembers,
                    subtitle: 'Daftar anggota di tabungan saat ini',
                    onTap: () => context.push('/home/profile/members'),
                  ),
                ] else ...[
                  SettingsTile(
                    icon: Icons.exit_to_app,
                    iconColor: Colors.redAccent,
                    title: AppStrings.leaveWallet,
                    subtitle: 'Keluar dari tabungan bersama ini',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Keluar Tabungan?'),
                          content: const Text(
                              'Anda akan kembali menggunakan Tabungan Pribadi.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Keluar',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirmed == true && wallet != null) {
                        ref.read(walletRepositoryProvider).leaveWallet(
                            wallet.walletId, user.uid, user.personalWalletId);
                      }
                    },
                  ),
                ],
                if (!isPersonal)
                  SettingsTile(
                    icon: Icons.swap_horiz,
                    title: 'Kembali ke Tabungan Pribadi',
                    subtitle: 'Beralih ke wallet pribadi Anda',
                    onTap: () => ref
                        .read(userRepositoryProvider)
                        .updateActiveWallet(user.uid, user.personalWalletId),
                  ),
                const SizedBox(height: 12),
                SettingsTile(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  title: AppStrings.logout,
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) context.go('/auth/login');
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
