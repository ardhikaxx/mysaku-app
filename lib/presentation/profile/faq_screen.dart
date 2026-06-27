import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../home/widgets/floating_capsule_app_bar.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _allFaqs = [
    {
      'category': 'Cash Flow',
      'q': 'Bagaimana cara menambah transaksi baru?',
      'a': 'Masuk ke menu utama "Cash Flow", kemudian tekan tombol melingkar bergambar ikon + di bagian bawah. Pilih jenis transaksi (Pemasukan / Pengeluaran), masukkan nominal, kategori, dan catatan.'
    },
    {
      'category': 'Cash Flow',
      'q': 'Bagaimana cara menghapus atau mengedit transaksi?',
      'a': 'Pada daftar transaksi di halaman Cash Flow, usap (swipe) kartu transaksi ke KIRI untuk menghapus, atau usap ke KANAN untuk mengedit detail transaksi tersebut.'
    },
    {
      'category': 'Impian (Dreams)',
      'q': 'Bagaimana cara kerja fitur Impian?',
      'a': 'Fitur Impian membantu Anda menargetkan dana tabungan khusus (seperti beli gadget atau liburan). Anda bisa menambah nominal tabungan yang sudah terkumpul secara berkala hingga mencapai target 100%.'
    },
    {
      'category': 'Tabungan Bersama',
      'q': 'Bagaimana cara mengundang anggota keluarga?',
      'a': 'Buka menu Profile, lalu klik opsi "Undang Anggota (maks. 5 orang)". Masukkan alamat email pasangan atau keluarga Anda. Mereka akan menerima undangan langsung di aplikasi MySaku mereka.'
    },
    {
      'category': 'Tabungan Bersama',
      'q': 'Apakah anggota lain bisa melihat transaksi saya?',
      'a': 'Jika Anda sedang berada di dalam Tabungan Bersama (Shared Wallet), semua anggota di dalam tabungan tersebut bisa melihat dan menambah transaksi. Namun jika Anda beralih ke Tabungan Pribadi, transaksi tersebut 100% privat untuk Anda.'
    },
    {
      'category': 'Keamanan & Data',
      'q': 'Bagaimana cara mengekspor laporan keuangan?',
      'a': 'Di halaman Profile, tekan menu "Ekspor Laporan Finansial". Anda bisa memilih format file Excel / CSV atau PDF rapi sesuai rentang waktu yang diinginkan.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _allFaqs.where((faq) {
      final query = _searchQuery.toLowerCase();
      return faq['q']!.toLowerCase().contains(query) || faq['a']!.toLowerCase().contains(query) || faq['category']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: 'Pertanyaan Umum (FAQ)',
        showBack: true,
        onLeadingTap: () => context.pop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari kata kunci (misal: hapus, impian, export)',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                    : null,
                filled: true,
                fillColor: AppColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
              ),
            ),
          ),
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.divider),
                        SizedBox(height: 12),
                        Text('Pertanyaan tidak ditemukan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Coba gunakan kata kunci pencarian lainnya', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final item = filteredFaqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                            title: Text(
                              item['q']!,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item['category']!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                              ),
                            ),
                            children: [
                              Text(
                                item['a']!,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
