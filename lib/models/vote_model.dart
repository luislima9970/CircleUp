import 'package:cloud_firestore/cloud_firestore.dart';

class VoteModel {
  final String voterId;
  final String vote;
  final Timestamp votedAt;

  VoteModel({
    required this.voterId,
    required this.vote,
    Timestamp? votedAt,
  }) : votedAt = votedAt ?? Timestamp.now();

  factory VoteModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return VoteModel(
        voterId: docId,
        vote: data['vote'] ?? '',
        votedAt: data['votedAt']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vote': vote,
      'votedAt': votedAt
    };
  }

}