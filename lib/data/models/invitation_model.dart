import 'package:cloud_firestore/cloud_firestore.dart';

class InvitationModel {
  final String invitationId;
  final String walletId;
  final String ownerId;
  final String ownerName;
  final String walletName;
  final String invitedEmail;
  final String? invitedUid;
  final String status; // "pending" | "accepted" | "declined" | "expired"
  final DateTime createdAt;
  final DateTime? expiresAt;

  const InvitationModel({
    required this.invitationId,
    required this.walletId,
    required this.ownerId,
    required this.ownerName,
    required this.walletName,
    required this.invitedEmail,
    this.invitedUid,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isPending => status == 'pending';
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => isPending && !isExpired;

  factory InvitationModel.fromJson(Map<String, dynamic> json) => InvitationModel(
        invitationId: json['invitationId'] as String? ?? '',
        walletId: json['walletId'] as String? ?? '',
        ownerId: json['ownerId'] as String? ?? '',
        ownerName: json['ownerName'] as String? ?? 'Owner',
        walletName: json['walletName'] as String? ?? 'Tabungan',
        invitedEmail: json['invitedEmail'] as String? ?? '',
        invitedUid: json['invitedUid'] as String?,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        expiresAt: json['expiresAt'] is Timestamp
            ? (json['expiresAt'] as Timestamp).toDate()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'invitationId': invitationId,
        'walletId': walletId,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'walletName': walletName,
        'invitedEmail': invitedEmail,
        'invitedUid': invitedUid,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      };
}
