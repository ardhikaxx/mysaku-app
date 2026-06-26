import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: iconColor ?? AppColors.primaryColor),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textPrimary,
                fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary))
            : null,
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: AppColors.divider),
      ),
    );
  }
}
