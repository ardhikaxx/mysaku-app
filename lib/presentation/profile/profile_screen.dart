import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invitation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showAppInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surfaceWhite,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 48, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'MySaku App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 1.0.0 (Build 100)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.code_rounded, size: 20, color: AppColors.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Dikembangkan oleh Yanuar Ardhika R.U',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi pencatatan keuangan dan target impian bersama untuk keluarga & pasangan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

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
      appBar: const FloatingCapsuleAppBar(
        title: AppStrings.profileTitle,
        leadingIcon: Icons.person_rounded,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }
          final isOwner = wallet?.ownerId == user.uid;
          final isPersonal = user.activeWalletId == user.personalWalletId;

          final List<Widget> tiles = [];

          if (invList.isNotEmpty) {
            tiles.add(SettingsTile(
              icon: Icons.mark_email_unread_outlined,
              title: 'Undangan Bergabung',
              subtitle: '${invList.length} undangan menunggu respon',
              trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('${invList.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              onTap: () => _showInvitationsModal(context, ref),
            ));
          }

          if (isOwner) {
            tiles.add(SettingsTile(
              icon: Icons.person_add_outlined,
              title: AppStrings.inviteMember,
              subtitle: 'Ajak keluarga atau pasangan (maks. 5 orang)',
              onTap: () => context.push('/home/profile/invite'),
            ));
            tiles.add(SettingsTile(
              icon: Icons.people_outline,
              title: AppStrings.manageMembers,
              subtitle: 'Daftar anggota di tabungan saat ini',
              onTap: () => context.push('/home/profile/members'),
            ));
          } else {
            tiles.add(SettingsTile(
              icon: Icons.exit_to_app,
              title: AppStrings.leaveWallet,
              subtitle: 'Keluar dari tabungan bersama ini',
              onTap: () async {
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Keluar Tabungan?',
                  message: 'Anda akan kembali menggunakan Tabungan Pribadi.',
                  confirmText: 'Keluar',
                  icon: Icons.exit_to_app,
                  iconColor: const Color(0xFFEF4444),
                );
                if (confirmed && wallet != null) {
                  ref.read(walletRepositoryProvider).leaveWallet(wallet.walletId, user.uid, user.personalWalletId);
                }
              },
            ));
          }

          if (!isPersonal) {
            tiles.add(SettingsTile(
              icon: Icons.swap_horiz,
              title: 'Kembali ke Tabungan Pribadi',
              subtitle: 'Beralih ke wallet pribadi Anda',
              onTap: () => ref.read(userRepositoryProvider).updateActiveWallet(user.uid, user.personalWalletId),
            ));
          }

          tiles.add(SettingsTile(
            icon: Icons.headset_mic_rounded,
            title: 'Pusat Bantuan',
            subtitle: 'Layanan dukungan pelanggan WhatsApp / Email',
            onTap: () => context.push('/home/profile/help'),
          ));
          tiles.add(SettingsTile(
            icon: Icons.question_answer_rounded,
            title: 'Pertanyaan Umum (FAQ)',
            subtitle: 'Panduan cara menghapus, edit, & fitur impian',
            onTap: () => context.push('/home/profile/faq'),
          ));
          tiles.add(SettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Kebijakan Privasi',
            subtitle: 'Komitmen perlindungan & enkripsi data Anda',
            onTap: () => context.push('/home/profile/privacy'),
          ));
          tiles.add(SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Info Aplikasi',
            subtitle: 'Versi 1.0.0 • Dikembangkan oleh Yanuar Ardhika R.U',
            onTap: () => _showAppInfoModal(context),
          ));

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Column(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        for (int i = 0; i < tiles.length; i++) ...[
                          tiles[i],
                          if (i < tiles.length - 1)
                            const Divider(height: 1, color: AppColors.divider, indent: 60),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Keluar Akun?',
                        message: 'Anda akan keluar dari akun MySaku. Pastikan data Anda sudah tersimpan.',
                        confirmText: 'Ya, Keluar',
                        icon: Icons.logout_rounded,
                        iconColor: Colors.red,
                        confirmColor: Colors.red,
                      );
                      if (confirmed && context.mounted) {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/auth/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    label: const Text(
                      AppStrings.logout,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.25), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
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
