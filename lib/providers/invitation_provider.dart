import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/invitation_model.dart';
import '../data/repositories/invitation_repository.dart';
import 'auth_provider.dart';

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  return InvitationRepository();
});

final userInvitationsProvider = StreamProvider<List<InvitationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null || user.email == null || user.email!.isEmpty) {
    return Stream.value([]);
  }

  final repo = ref.watch(invitationRepositoryProvider);
  return repo.getUserInvitationsStream(user.email!);
});
