import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import 'auth_provider.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);

  // Otomatis buat dokumen Firestore jika belum ada
  ref.read(authRepositoryProvider).ensureUserInitialized(authUser);

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserStream(authUser.uid);
});

final activeWalletIdProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).value?.activeWalletId;
});
