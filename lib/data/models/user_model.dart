import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String personalWalletId;
  final String activeWalletId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.personalWalletId,
    required this.activeWalletId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String? ?? '',
    name: json['name'] as String? ?? 'User',
    email: json['email'] as String? ?? '',
    photoUrl: json['photoUrl'] as String?,
    personalWalletId: json['personalWalletId'] as String? ?? '',
    activeWalletId: json['activeWalletId'] as String? ?? '',
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: json['updatedAt'] is Timestamp
        ? (json['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'personalWalletId': personalWalletId,
    'activeWalletId': activeWalletId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
