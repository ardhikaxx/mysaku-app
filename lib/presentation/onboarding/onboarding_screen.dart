import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.add_circle_outline,
      iconColor: const Color(0xFF3B82F6),
      title: 'Tambah Transaksi',
      description:
          'Catat pemasukan dan pengeluaran Anda dengan mudah. Tekan tombol + di halaman Cash Flow untuk menambah transaksi baru.',
    ),
    OnboardingPageData(
      icon: Icons.swipe_left_alt,
      iconColor: const Color(0xFFEF4444),
      title: 'Hapus Transaksi',
      description:
          'Geser kiri pada transaksi untuk menghapusnya. Konfirmasi akan muncul sebelum penghapusan.',
    ),
    OnboardingPageData(
      icon: Icons.swipe_right_alt,
      iconColor: const Color(0xFF10B981),
      title: 'Edit Transaksi',
      description:
          'Geser kanan pada transaksi untuk mengeditnya. Ubah nama, jumlah, atau kategori sesuai kebutuhan.',
    ),
    OnboardingPageData(
      icon: Icons.rocket_launch_outlined,
      iconColor: const Color(0xFFD97706),
      title: 'Tambah Impian',
      description:
          'Tetapkan target tabungan impian Anda. Tekan tombol + di halaman Impian untuk menambah target baru.',
    ),
    OnboardingPageData(
      icon: Icons.swipe_left_alt,
      iconColor: const Color(0xFFEF4444),
      title: 'Hapus Impian',
      description:
          'Geser kiri pada impian untuk menghapusnya. Pastikan impian sudah tercapai sebelum menghapus.',
    ),
    OnboardingPageData(
      icon: Icons.swipe_right_alt,
      iconColor: const Color(0xFF10B981),
      title: 'Edit Impian',
      description:
          'Geser kanan pada impian untuk mengeditnya. Sesuaikan target atau tandai sebagai tercapai.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    ref.invalidate(onboardingCompletedProvider);
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: page.iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            color: page.iconColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF6B7280),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryColor
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_currentPage == _pages.length - 1
                        ? 'Selesai'
                        : 'Lanjut'),
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

class OnboardingPageData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
