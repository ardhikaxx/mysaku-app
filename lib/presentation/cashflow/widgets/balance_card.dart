import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../providers/privacy_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(walletBalanceProvider);
    final walletAsync = ref.watch(walletProvider);
    final isHidden = ref.watch(privacyProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Label Saldo & Eye Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Saldo',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      AppHaptics.lightTap();
                      ref.read(privacyProvider.notifier).toggleVisibility();
                    },
                    child: Icon(
                      isHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                  ),
                ],
              ),
              // Date & Time Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF60A5FA),
                      size: 11,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(_now),
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4B5563),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF60A5FA),
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_now),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Massive Clean Nominal
          Text(
            isHidden ? 'Rp ••••••••' : balance.toIDR,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 24),

          // Minimalist Separator
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 18),

          // Footer: Wallet Name & Member Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              walletAsync.when(
                data: (wallet) => Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Color(0xFF60A5FA), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      wallet?.name ?? 'Tabungan Utama',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                loading: () => const Text('Memuat...',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                error: (error, stack) => const Text('Tabungan',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              walletAsync.when(
                data: (wallet) => Text(
                  '👥 ${wallet?.memberIds.length ?? 1} Anggota',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                loading: () => const SizedBox(),
                error: (error, stack) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
