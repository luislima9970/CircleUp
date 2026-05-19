import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String userId;
  final int points;
  final int streak;
  final String role;
  final Timestamp joinedAt;

  MemberModel({
    required this.userId,
    int? points,
    int? streak,
    String? role,
    Timestamp? joinedAt,
  }) : points = points ?? 0,
        streak = streak ?? 0,
        role = role ?? 'member',
        joinedAt = joinedAt ?? Timestamp.now();

  factory MemberModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return MemberModel(
        userId: docId,
        points: data['points'] ?? 0,
        streak: data['streak'] ?? 0,
        role: data['role'] ?? '',
        joinedAt: data['joinedAt']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'points': points,
      'streak': streak,
      'role': role,
      'joinedAt': joinedAt
    };
  }

}