import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/dream_model.dart';

class DreamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<DreamModel>> getDreamsStream(String walletId) {
    return _firestore
        .collection(FirebaseConstants.wallets)
        .doc(walletId)
        .collection(FirebaseConstants.dreams)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => DreamModel.fromJson(doc.data())).toList());
  }

  Future<void> addDream(String walletId, DreamModel dream) async {
    try {
      final ref = _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.dreams)
          .doc();

      final newDream = DreamModel(
        dreamId: ref.id,
        name: dream.name,
        targetAmount: dream.targetAmount,
        description: dream.description,
        isAchieved: dream.isAchieved,
        createdBy: dream.createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.set(newDream.toJson());
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> updateDream(String walletId, DreamModel dream) async {
    try {
      final ref = _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.dreams)
          .doc(dream.dreamId);

      final updatedJson = dream.toJson();
      updatedJson['updatedAt'] = FieldValue.serverTimestamp();

      await ref.update(updatedJson);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> deleteDream(String walletId, String dreamId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.dreams)
          .doc(dreamId)
          .delete();
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
