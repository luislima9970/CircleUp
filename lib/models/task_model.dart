import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String title;
  final String objective;
  final int reward;
  final Timestamp createdAt;
  final bool isActive;

  TaskModel({
    this.id,
    required this.title,
    required this.objective,
    required this.reward,
    Timestamp? createdAt,
    this.isActive = false
  }) : createdAt = createdAt ?? Timestamp.now();

  factory TaskModel.fromFirestore(
      Map<String, dynamic> data,
      String docId,
      ) {
    return TaskModel(
      id: docId,
      title: data['title'] ?? '',
      objective: data['objective'] ?? '',
      reward: data['reward'] ?? '',
      createdAt: data['createdAt'],
      isActive: data['isActive']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'objective': objective,
      'reward': reward,
      'createdAt': createdAt,
      'isActive': isActive
    };
  }

}