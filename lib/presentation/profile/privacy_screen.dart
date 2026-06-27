import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../home/widgets/floating_capsule_app_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Kebijakan Privasi',
        showBack: true,
        onLeadingTap: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Komitmen Perlindungan Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Terakhir diperbarui: Juni 2026', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 24),
              _buildSection(
                '1. Pengumpulan Informasi Finansial',
                'Aplikasi MySaku mencatat nominal, kategori, dan keterangan transaksi yang Anda masukkan secara sadar untuk keperluan pembukuan keuangan pribadi maupun keluarga. Kami tidak mengakses PIN rekening bank atau kartu kredit fisik Anda.',
              ),
              _buildSection(
                '2. Enkripsi & Penyimpanan Cloud',
                'Seluruh data Anda disinkronisasi ke server Google Firebase Cloud Firestore dengan perlindungan keamanan SSL/TLS ganda. Hanya akun Anda dan anggota yang Anda undang ke Tabungan Bersama yang memiliki hak akses membaca data tersebut.',
              ),
              _buildSection(
                '3. Larangan Menjual Data ke Pihak Ketiga',
                'Kami berkomitmen penuh 100% TIDAK AKAN PERNAH memperjualbelikan, menyewakan, atau mendistribusikan riwayat finansial Anda kepada agensi iklan, biro kredit, atau pinjaman online mana pun.',
              ),
              _buildSection(
                '4. Hak Pengguna & Penghapusan Akun',
                'Anda memiliki kendali penuh atas data Anda. Kapan pun Anda memutuskan keluar atau menghapus akun melalui menu Pengaturan, seluruh riwayat transaksi di database kami akan ikut dimusnahkan secara permanen tanpa sisa.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: Color(0xFF10B981)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dengan tetap menggunakan MySaku, Anda menyetujui seluruh standar keamanan privasi di atas.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
