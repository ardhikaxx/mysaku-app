import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/member_model.dart';

class MemberItemCard extends StatelessWidget {
  final MemberModel member;
  final bool isCurrentUser;
  final VoidCallback? onRemove;

  const MemberItemCard({
    super.key,
    required this.member,
    required this.isCurrentUser,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
          backgroundImage:
              member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
          child: member.photoUrl == null
              ? Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold))
              : null,
        ),
        title: Row(
          children: [
            Text(member.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('Anda',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
          ],
        ),
        subtitle: Text(member.email,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: member.isOwner
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Owner',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              )
            : (onRemove != null
                ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: onRemove)
                : null),
      ),
    );
  }
}
