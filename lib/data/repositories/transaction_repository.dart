import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransactionModel>> getTransactionsStream(String walletId) {
    return _firestore
        .collection(FirebaseConstants.wallets)
        .doc(walletId)
        .collection(FirebaseConstants.transactions)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addTransaction(String walletId, TransactionModel tx) async {
    try {
      final ref = _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.transactions)
          .doc();

      final newTx = TransactionModel(
        transactionId: ref.id,
        type: tx.type,
        name: tx.name,
        amount: tx.amount,
        category: tx.category,
        description: tx.description,
        transactionDate: tx.transactionDate,
        createdBy: tx.createdBy,
        createdByName: tx.createdByName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.set(newTx.toJson());
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> updateTransaction(String walletId, TransactionModel tx) async {
    try {
      final ref = _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.transactions)
          .doc(tx.transactionId);

      final updatedJson = tx.toJson();
      updatedJson['updatedAt'] = FieldValue.serverTimestamp();

      await ref.update(updatedJson);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> deleteTransaction(String walletId, String transactionId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.wallets)
          .doc(walletId)
          .collection(FirebaseConstants.transactions)
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
