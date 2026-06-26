import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String walletId;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final int maxMembers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletModel({
    required this.walletId,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    this.maxMembers = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isFull => memberIds.length >= maxMembers;
  bool get canInvite => memberIds.length < maxMembers;
  int get availableSlots => maxMembers - memberIds.length;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    walletId: json['walletId'] as String? ?? '',
    name: json['name'] as String? ?? 'Tabungan',
    ownerId: json['ownerId'] as String? ?? '',
    memberIds: List<String>.from(json['memberIds'] ?? []),
    maxMembers: json['maxMembers'] as int? ?? 5,
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'walletId': walletId,
    'name': name,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'maxMembers': maxMembers,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
