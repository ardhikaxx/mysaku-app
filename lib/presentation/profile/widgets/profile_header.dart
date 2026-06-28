import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/wallet_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider).value;
    final isPersonal = user.activeWalletId == user.personalWalletId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isPersonal
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : AppColors.accentAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPersonal ? Icons.person_outline : Icons.people_outline,
                  size: 16,
                  color: isPersonal
                      ? AppColors.primaryColor
                      : AppColors.accentAmber,
                ),
                const SizedBox(width: 6),
                Text(
                  isPersonal
                      ? 'Tabungan Pribadi'
                      : '${wallet?.name ?? "Tabungan Bersama"} (${wallet?.memberIds.length ?? 1}/5)',
                  style: TextStyle(
                    color: isPersonal
                        ? AppColors.primaryColor
                        : AppColors.accentAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
