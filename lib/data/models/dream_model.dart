import 'package:cloud_firestore/cloud_firestore.dart';

class DreamModel {
  final String dreamId;
  final String name;
  final double targetAmount;
  final String? description;
  final bool isAchieved;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DreamModel({
    required this.dreamId,
    required this.name,
    required this.targetAmount,
    this.description,
    this.isAchieved = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  double calculateProgress(double currentBalance) {
    if (targetAmount <= 0) return 0;
    return (currentBalance / targetAmount * 100).clamp(0, 100);
  }

  factory DreamModel.fromJson(Map<String, dynamic> json) => DreamModel(
        dreamId: json['dreamId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
        description: json['description'] as String?,
        isAchieved: json['isAchieved'] as bool? ?? false,
        createdBy: json['createdBy'] as String? ?? '',
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'dreamId': dreamId,
        'name': name,
        'targetAmount': targetAmount,
        'description': description,
        'isAchieved': isAchieved,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
