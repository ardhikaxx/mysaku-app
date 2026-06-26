import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String transactionId;
  final String type; // "income" | "expense"
  final String name;
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;
  final String createdBy; // UID
  final String createdByName; // Nama snapshot
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.transactionId,
    required this.type,
    required this.name,
    required this.amount,
    required this.category,
    this.description,
    required this.transactionDate,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        transactionId: json['transactionId'] as String? ?? '',
        type: json['type'] as String? ?? 'expense',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num? ?? 0).toDouble(),
        category: json['category'] as String? ?? 'other_expense',
        description: json['description'] as String?,
        transactionDate: json['transactionDate'] is Timestamp
            ? (json['transactionDate'] as Timestamp).toDate()
            : DateTime.now(),
        createdBy: json['createdBy'] as String? ?? '',
        createdByName: json['createdByName'] as String? ?? 'User',
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'type': type,
        'name': name,
        'amount': amount,
        'category': category,
        'description': description,
        'transactionDate': Timestamp.fromDate(transactionDate),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
