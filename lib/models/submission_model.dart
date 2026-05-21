import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String userId;
  final String? photoUrl;
  final String status;
  final int validVotes;
  final int invalidVotes;
  final Timestamp createdAt;

  SubmissionModel({
    required this.userId,
    this.photoUrl,
    this.status = 'PENDING',
    this.validVotes = 0,
    this.invalidVotes = 0,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory SubmissionModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return SubmissionModel(
      userId: docId,
      photoUrl: data['photoUrl'] ?? '',
      status: data['status'] ?? '',
      validVotes: data['validVotes'] ?? 0,
      invalidVotes: data['invalidVotes'] ?? 0,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photoUrl': photoUrl,
      'status': status,
      'validVotes': validVotes,
      'invalidVotes': invalidVotes,
      'createdAt': createdAt
    };
  }

}