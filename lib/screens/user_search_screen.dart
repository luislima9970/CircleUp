import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _initial(String username) {
    final trimmed = username.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      title: 'Find People',
                      onBack: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _query = value.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by username',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF7A8A94),
                        ),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF7A8A94),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.96),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: Color(0xFF2A8CFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _LoadingCard();
                        }

                        if (snapshot.hasError) {
                          return const _EmptyStateCard(
                            icon: Icons.error_outline_rounded,
                            title: 'Could not load users',
                            subtitle: 'There was a problem searching users.',
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final users = docs.where((doc) {
                          if (doc.id == currentUserId) {
                            return false;
                          }

                          final data = doc.data();
                          final username =
                              data['username']?.toString().toLowerCase() ?? '';

                          if (_query.isEmpty) {
                            return false;
                          }

                          return username.contains(_query);
                        }).toList();

                        if (_query.isEmpty) {
                          return const _EmptyStateCard(
                            icon: Icons.search_rounded,
                            title: 'Search for people',
                            subtitle:
                            'Type a username to find other users in the app.',
                          );
                        }

                        if (users.isEmpty) {
                          return const _EmptyStateCard(
                            icon: Icons.person_search_rounded,
                            title: 'No users found',
                            subtitle: 'Try searching for another username.',
                          );
                        }

                        return Column(
                          children: [
                            for (int i = 0; i < users.length; i++) ...[
                              _UserResultCard(
                                userId: users[i].id,
                                data: users[i].data(),
                                initial: _initial(
                                  users[i].data()['username']?.toString() ??
                                      'User',
                                ),
                              ),
                              if (i != users.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
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
}

class _UserResultCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  final String initial;

  const _UserResultCard({
    required this.userId,
    required this.data,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final username = data['username']?.toString() ?? 'User';

    final phrase = data['profilePhrase']?.toString().trim().isNotEmpty == true
        ? data['profilePhrase'].toString().trim()
        : 'Turning small actions into daily impact.';

    final photoUrl = data['photoUrl']?.toString().trim() ?? '';

    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _SearchedUserProfileScreen(
                userId: userId,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFEAF4FF),
                backgroundImage:
                photoUrl.isEmpty ? null : NetworkImage(photoUrl),
                child: photoUrl.isEmpty
                    ? Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF2A8CFF),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      phrase,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF7A8A94),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF95A39A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchedUserProfileScreen extends StatefulWidget {
  final String userId;

  const _SearchedUserProfileScreen({
    required this.userId,
  });

  @override
  State<_SearchedUserProfileScreen> createState() =>
      _SearchedUserProfileScreenState();
}

class _SearchedUserProfileScreenState
    extends State<_SearchedUserProfileScreen> {
  late Future<_SearchedUserProfileData> _profileFuture;

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

  Future<_SearchedUserProfileData> _loadProfile() async {
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

    int totalPoints = 0;
    int completedTasks = 0;
    int groupsCount = 0;
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
      debugPrint('Could not load searched user completions: $e');
    }

    try {
      final membersSnapshot = await firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: widget.userId)
          .get();

      groupsCount = membersSnapshot.docs.length;
    } catch (e) {
      debugPrint('Could not load searched user groups: $e');
    }

    return _SearchedUserProfileData(
      username: username,
      phrase: phrase,
      photoUrl: photoUrl,
      completedTasks: completedTasks,
      totalPoints: totalPoints,
      groupsCount: groupsCount,
      streak: _calculateStreak(completedDates),
    );
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
              FutureBuilder<_SearchedUserProfileData>(
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

                        _ProfileHeaderCard(
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
                                value: profile.groupsCount.toString(),
                                label: 'Groups',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        _ProfileInfoCard(
                          completedTasks: profile.completedTasks,
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

class _SearchedUserProfileData {
  final String username;
  final String phrase;
  final String photoUrl;
  final int completedTasks;
  final int totalPoints;
  final int groupsCount;
  final int streak;

  const _SearchedUserProfileData({
    required this.username,
    required this.phrase,
    required this.photoUrl,
    required this.completedTasks,
    required this.totalPoints,
    required this.groupsCount,
    required this.streak,
  });
}

class _ProfileHeaderCard extends StatelessWidget {
  final String username;
  final String phrase;
  final String initial;
  final String photoUrl;

  const _ProfileHeaderCard({
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

class _ProfileInfoCard extends StatelessWidget {
  final int completedTasks;

  const _ProfileInfoCard({
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

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
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
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2A8CFF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF7A8A94),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2A8CFF),
        ),
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