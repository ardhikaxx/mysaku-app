import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(walletBalanceProvider);
    final walletAsync = ref.watch(walletProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Sleek Jet Black / Midnight
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withOpacity(0.25),
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
                    onTap: () => setState(() => _isHidden = !_isHidden),
                    child: Icon(
                      _isHidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 18,
                    ),
                  ),
                ],
              ),
              // Live Sync Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Realtime',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
            _isHidden ? 'Rp ••••••••' : balance.toIDR,
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
            color: Colors.white.withOpacity(0.08),
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
                error: (_, __) => const Text('Tabungan',
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
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
