import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/invitation_model.dart';

class InvitationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendInvitation({
    required String walletId,
    required String ownerId,
    required String ownerName,
    required String walletName,
    required String invitedEmail,
  }) async {
    try {
      // 1. Cek jumlah member di wallet
      final membersSnap = await _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.members)
          .get();

      if (membersSnap.docs.length >= 5) {
        throw const AppException(
            'Kapasitas tabungan bersama sudah penuh (maksimal 5 anggota)');
      }

      // 2. Cek apakah sudah jadi member
      final isAlreadyMember = membersSnap.docs.any((doc) =>
          (doc.data()['email'] as String?).toString().toLowerCase() ==
          invitedEmail.toLowerCase());
      if (isAlreadyMember) {
        throw const AppException(
            'Pengguna dengan email tersebut sudah menjadi anggota');
      }

      // 3. Cek apakah ada undangan pending untuk email yang sama di wallet ini
      final existingInv = await _firestore
          .collection(FirebaseConstants.invitations)
          .where('walletId', isEqualTo: walletId)
          .where('invitedEmail', isEqualTo: invitedEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingInv.docs.isNotEmpty) {
        throw const AppException(
            'Undangan tertunda sudah dikirim ke email tersebut');
      }

      final ref = _firestore.collection(FirebaseConstants.invitations).doc();
      final now = DateTime.now();

      final inv = InvitationModel(
        invitationId: ref.id,
        walletId: walletId,
        ownerId: ownerId,
        ownerName: ownerName,
        walletName: walletName,
        invitedEmail: invitedEmail,
        status: 'pending',
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      await ref.set(inv.toJson());
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Stream<List<InvitationModel>> getUserInvitationsStream(String email) {
    return _firestore
        .collection(FirebaseConstants.invitations)
        .where('invitedEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InvitationModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> respondInvitation(
      String invitationId, bool accept, String uid) async {
    try {
      final ref =
          _firestore.collection(FirebaseConstants.invitations).doc(invitationId);
      final doc = await ref.get();
      if (!doc.exists) return;

      final inv = InvitationModel.fromJson(doc.data()!);
      if (!inv.isPending) return;

      if (!accept) {
        await ref.update({'status': 'declined'});
        return;
      }

      final now = DateTime.now();
      final userDocRef =
          _firestore.collection(FirebaseConstants.users).doc(uid);
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) return;
      final userData = userDoc.data()!;
      final userName = userData['name'] as String? ?? 'User';
      final userEmail = userData['email'] as String? ?? '';
      final userPhoto = userData['photoUrl'] as String?;

      final walletRef =
          _firestore.collection(FirebaseConstants.wallets).doc(inv.walletId);

      final batch = _firestore.batch();
      batch.update(ref, {'status': 'accepted', 'invitedUid': uid});
      batch.update(walletRef, {
        'memberIds': FieldValue.arrayUnion([uid]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.set(
        walletRef.collection(FirebaseConstants.members).doc(uid),
        {
          'uid': uid,
          'name': userName,
          'email': userEmail,
          'photoUrl': userPhoto,
          'role': 'member',
          'joinedAt': Timestamp.fromDate(now),
        },
      );

      batch.update(userDocRef, {
        'activeWalletId': inv.walletId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
