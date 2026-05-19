import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String email;
  final String? photoUrl;
  final int totalPoints;
  final int maxStreak;
  final Timestamp createdAt;


  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    required this.totalPoints,
    required this.maxStreak,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory UserModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return UserModel(
      id: docId,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      totalPoints: data['totalPoints'] ?? 0,
      maxStreak: data['maxStreak'] ?? 0,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'maxStreak': maxStreak,
      'createdAt': createdAt,
    };
  }

}

String generateJoinCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(6, (index) {
    final rand = DateTime.now().microsecondsSinceEpoch + index;
    return chars[rand % chars.length];
  }).join();
}