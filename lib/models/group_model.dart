import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String? id;
  final String name;
  final String theme;
  final String description;
  final Timestamp createdAt;
  final String joinCode;

  GroupModel({
    this.id,
    required this.name,
    required this.theme,
    required this.description,
    Timestamp? createdAt,
    String? joinCode,
  }) : createdAt = createdAt ?? Timestamp.now(),
        joinCode = joinCode ?? generateJoinCode();

  factory GroupModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return GroupModel(
      id: docId,
      name: data['name'] ?? '',
      theme: data['theme'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'],
      joinCode: data['joinCode']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'theme': theme,
      'description': description,
      'createdAt': createdAt,
      'joinCode': joinCode,
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