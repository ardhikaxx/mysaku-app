import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/app_toast.dart';
import '../../providers/notification_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';

class DailyReminderScreen extends ConsumerWidget {
  const DailyReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderState = ref.watch(dailyReminderProvider);
    final notifier = ref.read(dailyReminderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Pengingat Catat Harian',
        showBack: true,
        onLeadingTap: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primaryColor,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pengingat Keuangan Pintar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Toggle Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Pengingat',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Aktif secara otomatis (Default)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: reminderState.isEnabled,
                          activeTrackColor: AppColors.primaryColor,
                          onChanged: (val) {
                            AppHaptics.lightTap();
                            notifier.toggleReminder(val);
                            if (val) {
                              AppToast.showSuccess(context, 'Pengingat otomatis diaktifkan');
                            } else {
                              AppToast.showSuccess(context, 'Pengingat dinonaktifkan');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Uji Coba Tombol
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tes Keandalan Getaran & Notifikasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ketuk tombol di bawah lalu segera matikan layar HP Anda untuk membuktikan notifikasi tetap muncul & bergetar saat layar tertutup.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppHaptics.successFeedback();
                        NotificationService().showInstantTestNotification();
                        AppToast.showSuccess(context, '🔔 Tes dikirim! Segera matikan/tutup layar HP Anda.');
                      },
                      icon: const Icon(Icons.vibration_rounded,
                          size: 18, color: AppColors.primaryColor),
                      label: const Text(
                        'Coba Tes Getaran Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
