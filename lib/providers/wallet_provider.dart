import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/member_model.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/wallet_repository.dart';
import 'user_provider.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletProvider = StreamProvider<WalletModel?>((ref) {
  final walletId = ref.watch(activeWalletIdProvider);
  if (walletId == null || walletId.isEmpty) return Stream.value(null);

  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWalletStream(walletId);
});

final membersProvider = StreamProvider<List<MemberModel>>((ref) {
  final walletId = ref.watch(activeWalletIdProvider);
  if (walletId == null || walletId.isEmpty) return Stream.value([]);

  final repo = ref.watch(walletRepositoryProvider);
  return repo.getMembersStream(walletId);
});
