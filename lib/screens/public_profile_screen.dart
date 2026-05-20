import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String? groupId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.groupId,
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

  Future<List<_PublicProfileGroupData>> _loadUserGroups(
      FirebaseFirestore firestore,
      ) async {
    final groups = <_PublicProfileGroupData>[];
    final seenGroupIds = <String>{};

    try {
      final allGroupsSnapshot = await firestore.collection('groups').get();

      for (final groupDoc in allGroupsSnapshot.docs) {
        final groupId = groupDoc.id;

        if (seenGroupIds.contains(groupId)) {
          continue;
        }

        bool isMember = false;

        try {
          final directMemberDoc = await firestore
              .collection('groups')
              .doc(groupId)
              .collection('members')
              .doc(widget.userId)
              .get();

          if (directMemberDoc.exists) {
            isMember = true;
          }
        } catch (e) {
          debugPrint('Could not check direct member doc for $groupId: $e');
        }

        if (!isMember) {
          try {
            final memberQuery = await firestore
                .collection('groups')
                .doc(groupId)
                .collection('members')
                .where('userId', isEqualTo: widget.userId)
                .limit(1)
                .get();

            if (memberQuery.docs.isNotEmpty) {
              isMember = true;
            }
          } catch (e) {
            debugPrint('Could not query member field for $groupId: $e');
          }
        }

        if (!isMember) {
          continue;
        }

        seenGroupIds.add(groupId);

        final groupData = groupDoc.data();

        final groupName = groupData['name']?.toString() ?? 'Unnamed group';
        final groupTheme = groupData['theme']?.toString() ?? '';

        groups.add(
          _PublicProfileGroupData(
            id: groupId,
            name: groupName,
            theme: groupTheme,
          ),
        );
      }

      groups.sort((a, b) {
        if (widget.groupId != null) {
          if (a.id == widget.groupId) return -1;
          if (b.id == widget.groupId) return 1;
        }

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return groups;
    } catch (e) {
      debugPrint('Could not load all public profile groups: $e');
      return [];
    }
  }

  Future<_PublicProfileData> _loadProfile() async {
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(widget.userId).get();
    final userData = userDoc.data() ?? {};

    final username =
    userData['username']?.toString().trim().isNotEmpty == true
        ? userData['username'].toString().trim()
        : 'User';

    final phrase =
    userData['profilePhrase']?.toString().trim().isNotEmpty == true
        ? userData['profilePhrase'].toString().trim()
        : 'Turning small actions into daily impact.';

    final photoUrl =
    userData['photoUrl']?.toString().trim().isNotEmpty == true
        ? userData['photoUrl'].toString().trim()
        : '';

    final groups = await _loadUserGroups(firestore);

    int totalPoints = 0;
    int completedTasks = 0;
    final completedDates = <String>{};

    try {
      final completionsSnapshot = await firestore
          .collectionGroup('taskCompletions')
          .where('userId', isEqualTo: widget.userId)
          .get();

      completedTasks = completionsSnapshot.docs.length;

      for (final completion in completionsSnapshot.docs) {
        final data = completion.data();

        totalPoints += _parseReward(data['reward']);

        final completedDate = data['completedDate']?.toString();

        if (completedDate != null && completedDate.isNotEmpty) {
          completedDates.add(completedDate);
        }
      }
    } catch (e) {
      debugPrint('Could not load public profile completions: $e');
    }

    return _PublicProfileData(
      username: username,
      phrase: phrase,
      photoUrl: photoUrl,
      groups: groups,
      completedTasks: completedTasks,
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
                    debugPrint('Public profile error: ${snapshot.error}');

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
                                icon: Icons.groups_rounded,
                                value: profile.groups.length.toString(),
                                label: 'Groups',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        _CompletedChallengesCard(
                          completedTasks: profile.completedTasks,
                        ),

                        const SizedBox(height: 22),

                        _GroupsCard(
                          groups: profile.groups,
                          themeColor: _themeColor,
                          themeIcon: _themeIcon,
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
  final List<_PublicProfileGroupData> groups;
  final int completedTasks;
  final int totalPoints;
  final int streak;

  const _PublicProfileData({
    required this.username,
    required this.phrase,
    required this.photoUrl,
    required this.groups,
    required this.completedTasks,
    required this.totalPoints,
    required this.streak,
  });
}

class _PublicProfileGroupData {
  final String id;
  final String name;
  final String theme;

  const _PublicProfileGroupData({
    required this.id,
    required this.name,
    required this.theme,
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

class _CompletedChallengesCard extends StatelessWidget {
  final int completedTasks;

  const _CompletedChallengesCard({
    required this.completedTasks,
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
              color: const Color(0xFF43D17A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF43D17A),
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completed challenges',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A8A94),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  completedTasks.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF1C2A33),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsCard extends StatelessWidget {
  final List<_PublicProfileGroupData> groups;
  final Color Function(String theme) themeColor;
  final IconData Function(String theme) themeIcon;

  const _GroupsCard({
    required this.groups,
    required this.themeColor,
    required this.themeIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const _EmptyGroupsCard();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF2A8CFF),
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Circles',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Communities this user belongs to',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8A94),
                        fontWeight: FontWeight.w600,
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
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  groups.length.toString(),
                  style: const TextStyle(
                    color: Color(0xFF2A8CFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Column(
            children: [
              for (int i = 0; i < groups.length; i++) ...[
                _GroupMiniRow(
                  group: groups[i],
                  color: themeColor(groups[i].theme),
                  icon: themeIcon(groups[i].theme),
                ),
                if (i != groups.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupMiniRow extends StatelessWidget {
  final _PublicProfileGroupData group;
  final Color color;
  final IconData icon;

  const _GroupMiniRow({
    required this.group,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8F0EA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C2A33),
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Text(
                      group.theme.isEmpty ? 'Circle' : group.theme,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A8A94),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGroupsCard extends StatelessWidget {
  const _EmptyGroupsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Color(0xFF2A8CFF),
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No visible circles',
                  style: TextStyle(
                    color: Color(0xFF1C2A33),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This user is not currently in any visible circles.',
                  style: TextStyle(
                    color: Color(0xFF7A8A94),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
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