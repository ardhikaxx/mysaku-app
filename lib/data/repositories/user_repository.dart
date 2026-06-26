import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(FirebaseConstants.users)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc =
          await _firestore.collection(FirebaseConstants.users).doc(uid).get();
      return doc.exists ? UserModel.fromJson(doc.data()!) : null;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> updateActiveWallet(String uid, String newWalletId) async {
    try {
      await _firestore.collection(FirebaseConstants.users).doc(uid).update({
        'activeWalletId': newWalletId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
