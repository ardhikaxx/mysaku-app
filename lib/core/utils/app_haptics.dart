import 'package:flutter/services.dart';

/// Utility untuk memberikan umpan balik getaran halus (Haptic Feedback)
/// yang memberikan kenyamanan sentuhan fisik pada pengguna aplikasi mobile.
class AppHaptics {
  /// Getaran sentuhan ringan saat menekan tombol cepat atau interaksi UI ringan.
  static Future<void> lightTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Getaran gembira ganda (sukses) saat data berhasil disimpan atau transaksi ditambahkan.
  static Future<void> successFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Getaran berat ganda (peringatan/error) saat terjadi kesalahan validasi atau kegagalan sistem.
  static Future<void> errorFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
