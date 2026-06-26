import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String role; // "owner" | "member"
  final DateTime joinedAt;

  const MemberModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
    required this.joinedAt,
  });

  bool get isOwner => role == 'owner';

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        uid: json['uid'] as String? ?? '',
        name: json['name'] as String? ?? 'Member',
        email: json['email'] as String? ?? '',
        photoUrl: json['photoUrl'] as String?,
        role: json['role'] as String? ?? 'member',
        joinedAt: json['joinedAt'] is Timestamp
            ? (json['joinedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role,
        'joinedAt': Timestamp.fromDate(joinedAt),
      };
}
