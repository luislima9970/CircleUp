import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String userId;
  final String username;
  final String? photoUrl;
  final int points;
  final int streak;
  final String role;
  final Timestamp joinedAt;

  MemberModel({
    required this.userId,
    required this.username,
    this.photoUrl,
    this.points = 0,
    this.streak = 0,
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
        points: data['points'] ?? 0,
        streak: data['streak'] ?? 0,
        role: data['role'] ?? '',
        joinedAt: data['joinedAt']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'photoUrl': photoUrl,
      'points': points,
      'streak': streak,
      'role': role,
      'joinedAt': joinedAt
    };
  }

}