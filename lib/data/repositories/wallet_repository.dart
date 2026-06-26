import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/member_model.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<WalletModel?> getWalletStream(String walletId) {
    return _firestore
        .collection(FirebaseConstants.wallets)
        .doc(walletId)
        .snapshots()
        .map((doc) => doc.exists ? WalletModel.fromJson(doc.data()!) : null);
  }

  Stream<List<MemberModel>> getMembersStream(String walletId) {
    return _firestore
        .collection(FirebaseConstants.wallets)
        .doc(walletId)
        .collection(FirebaseConstants.members)
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MemberModel.fromJson(doc.data())).toList());
  }

  Future<void> leaveWallet(
    String walletId,
    String uid,
    String personalWalletId,
  ) async {
    try {
      final batch = _firestore.batch();

      // 1. Remove member doc
      batch.delete(
        _firestore
            .collection(FirebaseConstants.wallets)
            .doc(walletId)
            .collection(FirebaseConstants.members)
            .doc(uid),
      );

      // 2. Remove from memberIds
      batch.update(
        _firestore.collection(FirebaseConstants.wallets).doc(walletId),
        {
          'memberIds': FieldValue.arrayRemove([uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // 3. Reset user activeWalletId
      batch.update(
        _firestore.collection(FirebaseConstants.users).doc(uid),
        {
          'activeWalletId': personalWalletId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
