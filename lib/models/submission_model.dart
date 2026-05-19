import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String userId;
  final String photoUrl;
  final String status;
  final Timestamp createdAt;

  SubmissionModel({
    required this.userId,
    required this.photoUrl,
    String? status,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now(),
      status = status ?? 'PENDING';

  factory SubmissionModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return SubmissionModel(
      userId: docId,
      photoUrl: data['photoUrl'] ?? '',
      status: data['status'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photoUrl': photoUrl,
      'status': status,
      'createdAt': createdAt
    };
  }

}