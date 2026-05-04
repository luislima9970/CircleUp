import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projesof/screens/tasks_screen.dart';

class GroupPageScreen extends StatefulWidget {
  final String groupId;

  const GroupPageScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupPageScreen> createState() => _GroupPageScreenState();
}

class _GroupPageScreenState extends State<GroupPageScreen> {
  int _selectedTab = 0;

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openTasksPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TasksPageScreen(userId: user!.uid),
      ),
    );
  }

  Color _themeColor(String theme) {
    if (theme == 'Fitness') {
      return const Color(0xFF2A8CFF);
    }

    if (theme == 'Wellness') {
      return const Color(0xFFFFB84D);
    }

    if (theme == 'Sustainability') {
      return const Color(0xFF43D17A);
    }

    return const Color(0xFF2A8CFF);
  }

  IconData _themeIcon(String theme) {
    if (theme == 'Fitness') {
      return Icons.fitness_center_rounded;
    }

    if (theme == 'Wellness') {
      return Icons.self_improvement_rounded;
    }

    if (theme == 'Sustainability') {
      return Icons.eco_rounded;
    }

    return Icons.groups_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingPage();
          }

          if (groupSnapshot.hasError) {
            return const _ErrorPage(
              message: 'Could not load this group.',
            );
          }

          final groupDoc = groupSnapshot.data;

          if (groupDoc == null || !groupDoc.exists) {
            return const _ErrorPage(
              message: 'This group does not exist.',
            );
          }

          final groupData = groupDoc.data() ?? {};
          final joinCode = groupData['joinCode']?.toString() ?? '';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('members')
                .snapshots(),
            builder: (context, membersSnapshot) {
              final members = membersSnapshot.data?.docs ?? [];

              final name = groupData['name']?.toString() ?? 'Unnamed group';
              final theme = groupData['theme']?.toString() ?? '';
              final description = groupData['description']?.toString() ?? '';

              final color = _themeColor(theme);
              final icon = _themeIcon(theme);

              return Container(
                width: double.infinity,
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
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TopBar(
                              onBack: () => Navigator.pop(context),
                            ),

                            const SizedBox(height: 24),

                            _GroupSummaryCard(
                              name: name,
                              theme: theme,
                              description: description,
                              memberCount: members.length,
                              taskCount: 0,
                              pendingCount: 0,
                              color: color,
                              icon: icon,
                            ),

                            const SizedBox(height: 24),

                            _JoinCodeCard(
                              joinCode: joinCode,
                              color: color,
                            ),

                            const SizedBox(height: 24),

                            _MembersCard(
                              members: members,
                              color: color,
                            ),

                            const SizedBox(height: 24),

                            _TabSelector(
                              selectedIndex: _selectedTab,
                              color: color,
                              onChanged: (index) {
                                setState(() {
                                  _selectedTab = index;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            if (_selectedTab == 0)
                              _TasksTab(color: color)
                            else
                              _LeaderboardTab(
                                members: members,
                                color: color,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2A8CFF),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }

          if (index == 1) {
            return;
          }

          if (index == 2) {
            _openTasksPage(context);
          }

          if (index == 3) {
            _showComingSoon('Profile page will be available soon.');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rtl),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({
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
        const Expanded(
          child: Text(
            'Circle Details',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C2A33),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupSummaryCard extends StatelessWidget {
  final String name;
  final String theme;
  final String description;
  final int memberCount;
  final int taskCount;
  final int pendingCount;
  final Color color;
  final IconData icon;

  const _GroupSummaryCard({
    required this.name,
    required this.theme,
    required this.description,
    required this.memberCount,
    required this.taskCount,
    required this.pendingCount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1C2A33),
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (theme.isNotEmpty)
                      Text(
                        theme,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InlineStat(
                    value: memberCount.toString(),
                    label: 'Members',
                    icon: Icons.people_alt_rounded,
                    color: color,
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: color.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _InlineStat(
                    value: taskCount.toString(),
                    label: 'Tasks',
                    icon: Icons.checklist_rounded,
                    color: color,
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: color.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _InlineStat(
                    value: pendingCount.toString(),
                    label: 'Pending',
                    icon: Icons.hourglass_top_rounded,
                    color: color,
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

class _InlineStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _InlineStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1C2A33),
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7A8A94),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MembersCard extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> members;
  final Color color;

  const _MembersCard({
    required this.members,
    required this.color,
  });

  String _initials(String username) {
    final clean = username.trim();

    if (clean.isEmpty) {
      return '?';
    }

    final parts = clean.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          const Text(
            'Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: members.isEmpty
                ? const Text(
              'No members',
              style: TextStyle(
                color: Color(0xFF7A8A94),
              ),
            )
                : SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final data = members[index].data();
                  final username =
                      data['username']?.toString() ?? 'User';

                  return CircleAvatar(
                    radius: 21,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Text(
                      _initials(username),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final int selectedIndex;
  final Color color;
  final ValueChanged<int> onChanged;

  const _TabSelector({
    required this.selectedIndex,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Tasks',
            selected: selectedIndex == 0,
            color: color,
            onTap: () => onChanged(0),
          ),
          _TabButton(
            label: 'Leaderboard',
            selected: selectedIndex == 1,
            color: color,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : const Color(0xFF7A8A94),
            ),
          ),
        ),
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  final Color color;

  const _TasksTab({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _EmptyContentCard(
      icon: Icons.checklist_rtl_rounded,
      title: 'No tasks yet',
      subtitle: 'Tasks connected to this group will appear here.',
      color: color,
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> members;
  final Color color;

  const _LeaderboardTab({
    required this.members,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMembers = [...members];

    sortedMembers.sort((a, b) {
      final aPoints = (a.data()['points'] as num?)?.toInt() ?? 0;
      final bPoints = (b.data()['points'] as num?)?.toInt() ?? 0;

      return bPoints.compareTo(aPoints);
    });

    if (sortedMembers.isEmpty) {
      return _EmptyContentCard(
        icon: Icons.leaderboard_rounded,
        title: 'No leaderboard yet',
        subtitle: 'Members will appear here once they join this group.',
        color: color,
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 210,
      ),
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < sortedMembers.length; i++) ...[
            _LeaderboardRow(
              position: i + 1,
              member: sortedMembers[i],
              color: color,
            ),
            if (i != sortedMembers.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int position;
  final QueryDocumentSnapshot<Map<String, dynamic>> member;
  final Color color;

  const _LeaderboardRow({
    required this.position,
    required this.member,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final data = member.data();

    final username = data['username']?.toString() ?? 'User';
    final points = (data['points'] as num?)?.toInt() ?? 0;
    final streak = (data['streak'] as num?)?.toInt() ?? 0;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '#$position',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2A33),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$streak day streak',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7A8A94),
                ),
              ),
            ],
          ),
        ),
        Text(
          '$points pts',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _EmptyContentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EmptyContentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 210,
      ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              color: color,
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

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2A8CFF),
        ),
      ),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final String message;

  const _ErrorPage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFF1C2A33),
            fontWeight: FontWeight.w700,
          ),
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
class _JoinCodeCard extends StatefulWidget {
  final String joinCode;
  final Color color;

  const _JoinCodeCard({
    required this.joinCode,
    required this.color,
  });

  @override
  State<_JoinCodeCard> createState() => _JoinCodeCardState();
}

class _JoinCodeCardState extends State<_JoinCodeCard> {
  bool _copied = false;

  void _copy() async {
    if (widget.joinCode.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: widget.joinCode),
    );

    setState(() => _copied = true);


    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invite Code',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C2A33),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.joinCode,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: color,
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AnimatedOpacity(
                      opacity: _copied ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedSlide(
                        offset: _copied
                            ? Offset.zero
                            : const Offset(0.3, 0),
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            'Copied!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),
                    ),


                    GestureDetector(
                      onTap: _copy,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _copied ? color.withValues(alpha: 0.9) : color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                          child: _copied
                              ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('check'),
                            color: Colors.white,
                            size: 18,
                          )
                              : const Icon(
                            Icons.copy_rounded,
                            key: ValueKey('copy'),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Share this code so others can join your group.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8A94),
            ),
          ),
        ],
      ),
    );
  }
}