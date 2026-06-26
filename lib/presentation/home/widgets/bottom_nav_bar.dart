import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              height: 65,
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              backgroundColor: AppColors.surfaceWhite,
              indicatorColor: AppColors.primaryColor.withOpacity(0.15),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.swap_horiz_outlined),
                  selectedIcon:
                      Icon(Icons.swap_horiz, color: AppColors.primaryColor),
                  label: 'Cashflow',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon:
                      Icon(Icons.auto_awesome, color: AppColors.accentAmber),
                  label: 'Impian',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon:
                      Icon(Icons.person, color: AppColors.primaryColor),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
