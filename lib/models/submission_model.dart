import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String userId;
  final String? photoUrl;
  String status;
  int validVotes;
  int invalidVotes;
  Timestamp? completedAt;

  SubmissionModel({
    required this.userId,
    this.photoUrl,
    this.status = 'PENDING',
    this.validVotes = 0,
    this.invalidVotes = 0,
    this.completedAt
  });

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
      completedAt: data['completedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photoUrl': photoUrl,
      'status': status,
      'validVotes': validVotes,
      'invalidVotes': invalidVotes,
      'completedAt': completedAt
    };
  }

}