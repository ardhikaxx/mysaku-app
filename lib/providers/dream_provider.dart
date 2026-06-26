import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/dream_model.dart';
import '../data/repositories/dream_repository.dart';
import 'user_provider.dart';

final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  return DreamRepository();
});

final dreamsProvider = StreamProvider<List<DreamModel>>((ref) {
  final walletId = ref.watch(activeWalletIdProvider);
  if (walletId == null || walletId.isEmpty) return Stream.value([]);

  final repo = ref.watch(dreamRepositoryProvider);
  return repo.getDreamsStream(walletId);
});
