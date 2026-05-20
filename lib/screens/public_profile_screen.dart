import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String groupId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.groupId,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late Future<_PublicProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  int _parseReward(dynamic reward) {
    if (reward is int) return reward;
    if (reward is num) return reward.toInt();
    if (reward is String) return int.tryParse(reward) ?? 0;
    return 0;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  int _calculateStreak(Set<String> completedDates) {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    while (completedDates.contains(_dateKey(currentDate))) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String _initial(String username) {
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }

  Future<Map<String, dynamic>> _loadMemberData() async {
    final membersRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('members');

    final directMemberDoc = await membersRef.doc(widget.userId).get();

    if (directMemberDoc.exists) {
      return directMemberDoc.data() ?? {};
    }

    final query = await membersRef
        .where('userId', isEqualTo: widget.userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return {};
    }

    return query.docs.first.data();
  }

  Future<_PublicProfileData> _loadProfile() async {
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(widget.userId).get();

    final groupDoc =
    await firestore.collection('groups').doc(widget.groupId).get();

    final memberData = await _loadMemberData();

    final userData = userDoc.data() ?? {};
    final groupData = groupDoc.data() ?? {};

    final username =
    userData['username']?.toString().trim().isNotEmpty == true
        ? userData['username'].toString().trim()
        : memberData['username']?.toString().trim().isNotEmpty == true
        ? memberData['username'].toString().trim()
        : 'User';

    final phrase =
    userData['profilePhrase']?.toString().trim().isNotEmpty == true
        ? userData['profilePhrase'].toString().trim()
        : 'Turning small actions into daily impact.';

    final photoUrl =
    userData['photoUrl']?.toString().trim().isNotEmpty == true
        ? userData['photoUrl'].toString().trim()
        : memberData['photoUrl']?.toString().trim() ?? '';

    final groupName = groupData['name']?.toString() ?? 'Unknown group';
    final groupTheme = groupData['theme']?.toString() ?? '';

    final completionsSnapshot = await firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('taskCompletions')
        .where('userId', isEqualTo: widget.userId)
        .get();

    int totalPoints = 0;
    final completedDates = <String>{};

    for (final completion in completionsSnapshot.docs) {
      final data = completion.data();

      totalPoints += _parseReward(data['reward']);

      final completedDate = data['completedDate']?.toString();

      if (completedDate != null && completedDate.isNotEmpty) {
        completedDates.add(completedDate);
      }
    }

    return _PublicProfileData(
      username: username,
      phrase: phrase,
      photoUrl: photoUrl,
      groupName: groupName,
      groupTheme: groupTheme,
      completedTasks: completionsSnapshot.docs.length,
      totalPoints: totalPoints,
      streak: _calculateStreak(completedDates),
    );
  }

  Color _themeColor(String theme) {
    if (theme == 'Fitness') return const Color(0xFF2A8CFF);
    if (theme == 'Wellness') return const Color(0xFFFFB84D);
    if (theme == 'Sustainability') return const Color(0xFF43D17A);

    return const Color(0xFF2A8CFF);
  }

  IconData _themeIcon(String theme) {
    if (theme == 'Fitness') return Icons.fitness_center_rounded;
    if (theme == 'Wellness') return Icons.self_improvement_rounded;
    if (theme == 'Sustainability') return Icons.eco_rounded;

    return Icons.groups_rounded;
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
            colors: [
              Color(0xFFEAF4FF),
              Color(0xFFF8FCFF),
              Color(0xFFEFFAF3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: -90,
                right: -70,
                child: _BackgroundCircle(
                  size: 210,
                  color: Color(0x332A8CFF),
                ),
              ),
              const Positioned(
                bottom: -100,
                left: -80,
                child: _BackgroundCircle(
                  size: 230,
                  color: Color(0x3343D17A),
                ),
              ),
              FutureBuilder<_PublicProfileData>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2A8CFF),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text(
                        'Could not load profile.',
                        style: TextStyle(
                          color: Color(0xFF1C2A33),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }

                  final profile = snapshot.data!;
                  final color = _themeColor(profile.groupTheme);
                  final icon = _themeIcon(profile.groupTheme);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(
                          title: 'Profile',
                          onBack: () => Navigator.pop(context),
                        ),

                        const SizedBox(height: 24),

                        _PublicProfileHeaderCard(
                          username: profile.username,
                          phrase: profile.phrase,
                          initial: _initial(profile.username),
                          photoUrl: profile.photoUrl,
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.stars_rounded,
                                value: profile.totalPoints.toString(),
                                label: 'Points',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.local_fire_department_rounded,
                                value: profile.streak == 1
                                    ? '1 day'
                                    : '${profile.streak} days',
                                label: 'Streak',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ProfileStatCard(
                                icon: Icons.check_circle_rounded,
                                value: profile.completedTasks.toString(),
                                label: 'Done',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        _CircleContextCard(
                          groupName: profile.groupName,
                          groupTheme: profile.groupTheme,
                          color: color,
                          icon: icon,
                        ),
                      ],
                    ),
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

class _PublicProfileData {
  final String username;
  final String phrase;
  final String photoUrl;
  final String groupName;
  final String groupTheme;
  final int completedTasks;
  final int totalPoints;
  final int streak;

  const _PublicProfileData({
    required this.username,
    required this.phrase,
    required this.photoUrl,
    required this.groupName,
    required this.groupTheme,
    required this.completedTasks,
    required this.totalPoints,
    required this.streak,
  });
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1C2A33),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
        ),
      ],
    );
  }
}

class _PublicProfileHeaderCard extends StatelessWidget {
  final String username;
  final String phrase;
  final String initial;
  final String photoUrl;

  const _PublicProfileHeaderCard({
    required this.username,
    required this.phrase,
    required this.initial,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2A8CFF),
            Color(0xFF43D17A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x242A8CFF),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
              child: photoUrl.isEmpty
                  ? Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF2A8CFF),
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              )
                  : null,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            phrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xEFFFFFFF),
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF43D17A),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1C2A33),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A8A94),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleContextCard extends StatelessWidget {
  final String groupName;
  final String groupTheme;
  final Color color;
  final IconData icon;

  const _CircleContextCard({
    required this.groupName,
    required this.groupTheme,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1C2A33),
                    fontWeight: FontWeight.w900,
                  ),
                ),

                if (groupTheme.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    groupTheme,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.groups_rounded,
              color: color,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}