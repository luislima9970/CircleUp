import 'package:flutter/material.dart';
import 'package:projesof/models/submission_model.dart';
import 'package:projesof/models/task_model.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/models/vote_model.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/submission_service.dart';
import 'package:projesof/services/user_service.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ValidationScreen extends StatefulWidget {
  final String groupId;
  final TaskModel task;
  final String authorId;
  final String themeColor;
  final SubmissionService? submissionService;
  final GroupService? groupService;
  final UserService? userService;

  const ValidationScreen({
    super.key,
    required this.groupId,
    required this.task,
    required this.authorId,
    this.themeColor = 'Sustainability',
    this.submissionService,
    this.groupService,
    this.userService,
  });

  @override
  State<ValidationScreen> createState() =>
      _ValidationScreenState();
}

class _ValidationScreenState
    extends State<ValidationScreen> {
  late final SubmissionService _submissionService;
  late final GroupService _groupService;
  late final UserService _userService;
  bool _isLoading = false;
  String? _errorMessage;
  late Future<SubmissionModel?> _submissionFuture;
  final user = AppState.currentUser!;
  late final TaskModel _task;
  VoteModel? _myVote;

  @override
  void initState() {
    super.initState();
    _submissionService = widget.submissionService ?? SubmissionService();
    _groupService = widget.groupService ?? GroupService();
    _userService = widget.userService ?? UserService();
    _task = widget.task;
    _submissionFuture = _submissionService.getSubmissionByUser(groupId: widget.groupId, taskId: _task.id!, userId: widget.authorId);
    _loadMyVote();
  }

  Future<void> _loadMyVote() async {
    final vote = await _submissionService.getVoteByUser(
      groupId: widget.groupId,
      taskId: _task.id!,
      authorId: widget.authorId,
      voterId: user.id!,
    );
    if (mounted) setState(() => _myVote = vote);
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

  Future<void> _awardTaskPointsIfAccepted() async {
    final taskId = _task.id;

    if (taskId == null) {
      return;
    }

    final reward = _task.reward;

    final firestore = FirebaseFirestore.instance;

    final groupRef = firestore.collection('groups').doc(widget.groupId);

    final submissionRef = groupRef
        .collection('tasks')
        .doc(taskId)
        .collection('submissions')
        .doc(widget.authorId);

    final memberRef = groupRef
        .collection('members')
        .doc(widget.authorId);

    final userRef = firestore
        .collection('users')
        .doc(widget.authorId);

    await firestore.runTransaction((transaction) async {
      final submissionSnapshot = await transaction.get(submissionRef);

      if (!submissionSnapshot.exists) {
        return;
      }

      final data = submissionSnapshot.data();

      if (data == null) {
        return;
      }

      final status = data['status'] as String? ?? 'PENDING';
      final pointsAlreadyAwarded = data['pointsAwarded'] == true;

      if (status != 'APPROVED' || pointsAlreadyAwarded) {
        return;
      }

      transaction.update(submissionRef, {
        'pointsAwarded': true,
        'pointsAwardedAt': FieldValue.serverTimestamp(),
        'awardedPoints': reward,
      });

      transaction.set(
        memberRef,
        {
          'points': FieldValue.increment(reward),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        userRef,
        {
          'totalPoints': FieldValue.increment(reward),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        groupRef,
        {
          'totalPoints': FieldValue.increment(reward),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> _submitVote(String vote) async {
    if (_myVote != null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isValid = vote == 'VALID';

      await _submissionService.voteSubmission(
        groupId: widget.groupId,
        taskId: _task.id!,
        authorId: widget.authorId,
        voterId: user.id!,
        vote: VoteModel(
          voterId: user.id!,
          vote: vote,
        ),
      );

      await _submissionService.incrementVoteCount(
        groupId: widget.groupId,
        taskId: _task.id!,
        authorId: widget.authorId,
        isValid: isValid,
      );

      await _awardTaskPointsIfAccepted();

      if (widget.authorId == user.id) {
        final updatedUser = await _userService.getUserById(user.id!);

        if (updatedUser != null) {
          AppState.setCurrentUser(updatedUser);
        }
      }

      if (mounted) {
        setState(() {
          _myVote = VoteModel(
            voterId: user.id!,
            vote: vote,
          );
        });

        await _refreshSubmissionData();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isValid
                  ? 'Vote recorded: Approved'
                  : 'Vote recorded: Rejected',
            ),
            backgroundColor: _getThemeColor(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error voting: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshSubmissionData() async {
    setState(() {
      _submissionFuture = _submissionService.getSubmissionByUser(groupId: widget.groupId, taskId: _task.id!, userId: widget.authorId);
    });
  }

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
                child: BackgroundCircle(
                  size: 210,
                  color: Color.fromARGB(51, 42, 140, 255),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: BackgroundCircle(
                  size: 230,
                  color: Color.fromARGB(51, 67, 209, 122),
                ),
              ),
              FutureBuilder<SubmissionModel?>(
                future: _submissionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Could not load the submission.',
                        style: TextStyle(
                          color: _getThemeColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  final submission = snapshot.data;

                  if (submission == null) {
                    return Center(
                      child: Text(
                        'Submission not found.',
                        style: TextStyle(
                          color: _getThemeColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return FutureBuilder<UserModel?>(
                      future: _userService.getUserById(widget.authorId),
                      builder: (context, authorSnapshot) {
                        if (authorSnapshot.data == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final author = authorSnapshot.data!;
                        return SingleChildScrollView(
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
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
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
                                    'Validate Submission',
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
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: _getThemeColor().withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getThemeColor().withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.how_to_vote_outlined,
                                      color: _getThemeColor(),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Community Validator',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1C2A33),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Vote whether this proof should be approved or rejected by the community.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color(0xFF7A8A94),
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Submission Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C2A33),
                                ),
                              ),
                              const SizedBox(height: 12),
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
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Submitted by',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF95A39A),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                author.username,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1C2A33),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: submission.status == 'APPROVED'
                                                ? const Color(0xFFDFF5E3)
                                                : submission.status == 'REJECTED'
                                                ? const Color(0xFFFFE5E5)
                                                : const Color(0xFFE4F4EA),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            submission.status == 'APPROVED'
                                                ? 'Accepted'
                                                : submission.status == 'REJECTED'
                                                ? 'Rejected'
                                                : 'Pending',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: submission.status == 'APPROVED'
                                                  ? const Color(0xFF2F7F3F)
                                                  : submission.status == 'REJECTED'
                                                  ? const Color(0xFFD93030)
                                                  : const Color(0xFF6B7B89),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Task',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF95A39A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _task.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C2A33),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
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
                                    if (submission.photoUrl != null) ...[
                                      const SizedBox(height: 20),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          submission.photoUrl!,
                                          width: double.infinity,
                                          height: 240,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const SizedBox(height: 240),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Community vote',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C2A33),
                                ),
                              ),
                              const SizedBox(height: 12),
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
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        _VoteBadge(
                                          label: 'Approved',
                                          value: submission.validVotes.toString(),
                                          color: const Color(0xFF43D17A),
                                        ),
                                        _VoteBadge(
                                          label: 'Rejected',
                                          value: submission.invalidVotes.toString(),
                                          color: const Color(0xFFD63031),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    if (_myVote != null)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F8FB),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFE8EFF1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _myVote?.vote == 'VALID'
                                                  ? Icons.thumb_up_alt_rounded
                                                  : Icons.thumb_down_alt_rounded,
                                              color: _getThemeColor(),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'You have already voted: ${_myVote?.vote == 'VALID' ? 'Approve' : 'Reject'}.',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF1C2A33),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : () => _submitVote('VALID'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF43D17A,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    12,
                                                  ),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                                  : const Text(
                                                'Approve',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : () => _submitVote('INVALID'),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFFD63031),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    12,
                                                  ),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              child: Text(
                                                'Reject',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFFD63031),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5E5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Color(0xFFD63031),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFD63031),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoteBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _VoteBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}