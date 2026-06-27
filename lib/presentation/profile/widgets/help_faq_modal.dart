import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HelpFaqModal extends StatelessWidget {
  const HelpFaqModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HelpFaqModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara menambah atau menghapus transaksi?',
        'a': 'Untuk menambah transaksi baru, tekan tombol + di halaman Cash Flow. Untuk menghapus atau mengedit, geser (swipe) kartu transaksi ke kiri atau ke kanan di daftar transaksi.'
      },
      {
        'q': 'Bagaimana cara kerja Tabungan Bersama (Shared Wallet)?',
        'a': 'Anda bisa mengundang maksimal 5 anggota keluarga atau pasangan ke dalam tabungan bersama. Semua transaksi yang dicatat akan langsung bersinkronisasi secara real-time di HP semua anggota.'
      },
      {
        'q': 'Apakah data keuangan saya aman?',
        'a': 'Sangat aman! Seluruh data Anda dienkripsi dan disimpan di server cloud standar keamanan tinggi Google Firebase.'
      },
      {
        'q': 'Bagaimana cara beralih kembali ke Tabungan Pribadi?',
        'a': 'Buka menu Profile ini, lalu klik opsi "Kembali ke Tabungan Pribadi" atau switch tabungan di bagian atas.'
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pusat Bantuan & FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('Temukan jawaban cepat atau hubungi kami', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                )
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Butuh Bantuan Langsung?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(height: 4),
                              Text('Tim dukungan kami siap membantu Anda via WhatsApp / Email.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Membuka chat WhatsApp Support MySaku...')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1D4ED8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: const Text('Chat Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Pertanyaan Umum (FAQ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ...faqs.map((faq) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            title: Text(
                              faq['q']!,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            children: [
                              Text(
                                faq['a']!,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Kebijakan Privasi MySaku'),
                            content: const SingleChildScrollView(
                              child: Text(
                                'MySaku sangat menghargai privasi Anda. Kami tidak pernah menjual atau membagikan riwayat transaksi finansial pribadi Anda kepada pihak ketiga mana pun demi tujuan iklan.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti')),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.privacy_tip_outlined, size: 18, color: AppColors.textSecondary),
                      label: const Text('Baca Kebijakan Privasi & Ketentuan Layanan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
