import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String userId;
  final String username;
  final String? photoUrl;
  final String phrase;
  final int points;
  final String role;
  final Timestamp joinedAt;

  MemberModel({
    required this.userId,
    required this.username,
    this.photoUrl,
    this.phrase = '',
    this.points = 0,
    this.role = 'member',
    Timestamp? joinedAt,
  }) : joinedAt = joinedAt ?? Timestamp.now();

  factory MemberModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return MemberModel(
        userId: docId,
        username: data['username'] ?? 'User',
        photoUrl: data['photoUrl'] ?? '',
        phrase: data['phrase'] ?? '',
        points: data['points'] ?? 0,
        role: data['role'] ?? '',
        joinedAt: data['joinedAt']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'photoUrl': photoUrl,
      'phrase': phrase,
      'points': points,
      'role': role,
      'joinedAt': joinedAt
    };
  }

}