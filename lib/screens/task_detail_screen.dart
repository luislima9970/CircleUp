import 'package:flutter/material.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/screens/submission_screen.dart';
import 'package:projesof/screens/validation_screen.dart';
import 'package:projesof/services/submission_service.dart';

import '../app_state.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final String groupId;
  final TaskModel task;
  final String themeColor;

  const TaskDetailScreen({
    super.key,
    required this.groupId,
    required this.task,
    required this.themeColor,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final SubmissionService _submissionService = SubmissionService();
  final user = AppState.currentUser!;
  late final TaskModel _task = widget.task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF3),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF4FF), Color(0xFFF8FCFF), Color(0xFFEFFAF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -70,
                child: _BackgroundCircle(
                  size: 210,
                  color: Color.fromARGB(51, 42, 140, 255),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: _BackgroundCircle(
                  size: 230,
                  color: Color.fromARGB(51, 67, 209, 122),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF1C2A33),
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          'Task Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C2A33),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Task Info
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getThemeColor().withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getThemeIcon(),
                                  color: _getThemeColor(),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Challenge',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF95A39A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C2A33),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF95A39A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _task.objective,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1C2A33),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // User's Submission
                    FutureBuilder<SubmissionModel?>(
                      future: _submissionService.getSubmissionByUser(
                          groupId: widget.groupId,
                          taskId: _task.id!,
                          userId: user.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final submission = snapshot.data;
                        final hasSubmission = submission != null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Submission',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1C2A33),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!hasSubmission)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE8EFF1),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: _getThemeColor().withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: _getThemeColor(),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No submission yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C2A33),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Submit your proof to complete this challenge',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF95A39A),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SubmissionScreen(
                                                groupId: widget.groupId,
                                                task: _task,
                                                themeColor: widget.themeColor,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _getThemeColor(),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Submit Proof',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Status: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1C2A33),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                submission.status ==
                                                    'APPROVED'
                                                ? const Color(0xFFDFF5E3)
                                                : submission.status ==
                                                      'REJECTED'
                                                ? const Color(0xFFFFE5E5)
                                                : const Color(0xFFE4F4EA),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            submission.status ==
                                                    'APPROVED'
                                                ? 'Approved'
                                                : submission.status ==
                                                      'REJECTED'
                                                ? 'Rejected'
                                                : 'Pending',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  submission.status ==
                                                      'APPROVED'
                                                  ? const Color(0xFF2F7F3F)
                                                  : submission.status ==
                                                        'REJECTED'
                                                  ? const Color(0xFFD93030)
                                                  : const Color(0xFF6B7B89),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (submission.photoUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          submission.photoUrl!,
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          '${submission.validVotes} upvotes',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF43D17A),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '${submission.invalidVotes} downvotes',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFD63031),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    // Pending Submissions for Validation
                    Text(
                      'Pending Submissions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<SubmissionModel>>(
                      stream: _submissionService.getSubmissionsForTaskWithStatus(
                          groupId: widget.groupId,
                          taskId: _task.id!,
                          status: 'PENDING'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final submissions = snapshot.data;
                        final List<SubmissionModel> otherSubmissions = [];
                        if (submissions != null) {
                          for (final submission in submissions) {
                            if (submission.userId != user.id) otherSubmissions.add(submission);
                          }
                        }

                        if (otherSubmissions.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFF95A39A),
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No pending submissions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'All submissions have been validated',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF95A39A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: otherSubmissions.map((submission) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ValidationScreen(
                                      groupId: widget.groupId,
                                      task: _task,
                                      authorId: submission.userId,
                                      themeColor: widget.themeColor,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getThemeColor().withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: _getThemeColor(),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            submission.userId,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1C2A33),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '${submission.validVotes} upvotes',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF43D17A),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '${submission.invalidVotes} downvotes',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFFD63031),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF95A39A),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (widget.themeColor) {
      case 'Fitness':
        return const Color(0xFF2A8CFF);
      case 'Wellness':
        return const Color(0xFFFFB84D);
      case 'Sustainability':
      default:
        return const Color(0xFF43D17A);
    }
  }

  IconData _getThemeIcon() {
    switch (widget.themeColor) {
      case 'Fitness':
        return Icons.fitness_center_rounded;
      case 'Wellness':
        return Icons.self_improvement_rounded;
      case 'Sustainability':
      default:
        return Icons.eco_rounded;
    }
  }
}

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
