import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String email;
  final String? photoUrl;
  final String phrase;
  final int totalPoints;
  final int maxStreak;
  final Timestamp createdAt;


  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.photoUrl,
    this.phrase = '',
    this.totalPoints = 0,
    this.maxStreak = 0,
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
      phrase: data['phrase'] ?? '',
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
      'phrase': phrase,
      'totalPoints': totalPoints,
      'maxStreak': maxStreak,
      'createdAt': createdAt,
    };
  }

}