import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projesof/screens/tasks_screen.dart';

import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/user_service.dart';

import 'homepage_screen.dart';
import 'group_page.dart';
import 'joincircle_screen.dart';
import 'profile_screen.dart';

class CreateCircleScreen extends StatefulWidget {
  final bool startInCreateMode;
  final GroupService? groupService;
  final UserService? userService;

  const CreateCircleScreen({
    super.key,
    this.startInCreateMode = false,
    this.groupService,
    this.userService,
  });

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  late final GroupService _groupService;
  late final UserService _userService;

  final _formKey = GlobalKey<FormState>();
  final _circleNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTheme = 'Sustainability';
  bool _isLoading = false;
  late bool _showCreateForm;

  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    
    _groupService = widget.groupService ?? GroupService();
    _userService = widget.userService ?? UserService();

    _showCreateForm = widget.startInCreateMode;
    _groupsFuture = _loadUserGroups();
  }

  @override
  void dispose() {
    _circleNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _loadUserGroups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];
      return _groupService.getGroupsForUser(user.uid);
    } catch (_) {
      return [];
    }
  }

  void _openCreateForm() {
    setState(() {
      _showCreateForm = true;
    });
  }

  void _closeCreateForm() {
    _circleNameController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedTheme = 'Sustainability';
      _showCreateForm = false;
      _groupsFuture = _loadUserGroups();
    });
  }

  void _openJoinPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JoinGroupScreen(),
      ),
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

  void _openProfilePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomepageScreen(),
      ),
    );
  }

  IconData _selectedThemeIcon() {
    if (_selectedTheme == 'Fitness') {
      return Icons.fitness_center_rounded;
    }

    if (_selectedTheme == 'Wellness') {
      return Icons.self_improvement_rounded;
    }

    return Icons.eco_rounded;
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

  Future<void> _createCircle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to create a circle.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userDoc = await _userService.getUserById(user.uid);
      final userData = userDoc.data();

      String username = userData?['username']?.toString().trim() ?? '';

      if (username.isEmpty && user.displayName != null) {
        username = user.displayName!.trim();
      }

      if (username.isEmpty && user.email != null) {
        username = user.email!.split('@').first;
      }

      if (username.isEmpty) {
        username = 'User';
      }

      final photoUrl = userData?['photoUrl']?.toString();

      final createdGroupId = await _groupService.createGroupWithOwner(
        name: _circleNameController.text.trim(),
        description: _descriptionController.text.trim(),
        theme: _selectedTheme,
        createdBy: user.uid,
        username: username,
        photoUrl: photoUrl,
      );

      debugPrint('Circle created with id: $createdGroupId');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Circle created successfully!'),
        ),
      );

      _circleNameController.clear();
      _descriptionController.clear();

      setState(() {
        _selectedTheme = 'Sustainability';
        _showCreateForm = false;
        _groupsFuture = _loadUserGroups();
      });
    } catch (e) {
      debugPrint('Error creating circle: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating circle: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF3),
      body: _PageBackground(
        child: _showCreateForm ? _buildCreateForm() : _buildCirclesPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2A8CFF),
        unselectedItemColor: const Color(0xFF95A39A),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) {
            _goToHome();
          }

          if (index == 1) {
            if (_showCreateForm) {
              _closeCreateForm();
            } else {
              setState(() {
                _groupsFuture = _loadUserGroups();
              });
            }
            return;
          }

          if (index == 2) {
            _openTasksPage(context);
          }

          if (index == 3) {
            _openProfilePage();
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

  Widget _buildCirclesPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(
            title: 'Circles',
            subtitle: 'Manage your groups and challenges',
            onBack: _goToHome,
          ),

          const SizedBox(height: 30),

          FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            future: _groupsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingCard();
              }

              if (snapshot.hasError) {
                return const _MessageCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load groups',
                  subtitle: 'There was a problem loading your groups.',
                );
              }

              final groups = snapshot.data ?? [];

              if (groups.isEmpty) {
                return _NoGroupsCard(
                  onCreate: _openCreateForm,
                  onJoin: _openJoinPage,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Your Groups',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C2A33),
                    ),
                  ),

                  const SizedBox(height: 14),

                  for (int i = 0; i < groups.length; i++) ...[
                    _GroupCard(
                      groupDoc: groups[i],
                      icon: _themeIcon(
                        groups[i].data()['theme']?.toString() ?? '',
                      ),
                      color: _themeColor(
                        groups[i].data()['theme']?.toString() ?? '',
                      ),
                    ),
                    if (i != groups.length - 1) const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 30),

                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C2A33),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_rounded,
                          title: 'Create',
                          subtitle: 'Start a circle',
                          onTap: _openCreateForm,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.group_add_outlined,
                          title: 'Join',
                          subtitle: 'Enter a circle',
                          onTap: _openJoinPage,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                title: 'Create Circle',
                subtitle: 'Start a new group challenge',
                onBack: _closeCreateForm,
              ),

              const SizedBox(height: 24),

              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 30,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/Logo.png',
                    height: 110,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Create your Circle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2A33),
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Choose a name and theme to start a new challenge with your friends.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8A94),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFE5EEF5),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Circle Name',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2A33),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _circleNameController,
                        decoration: _inputDecoration(
                          'Enter circle name',
                          Icons.edit_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a circle name';
                          }

                          if (value.trim().length < 3) {
                            return 'Circle name must be at least 3 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2A33),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          'Describe your circle',
                          Icons.description_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2A33),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F7F2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedThemeIcon(),
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTheme,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Sustainability',
                                      child: Text('Sustainability'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Fitness',
                                      child: Text('Fitness'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Wellness',
                                      child: Text('Wellness'),
                                    ),
                                  ],
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedTheme = value;
                                      });
                                    }
                                  },
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1C2A33),
                                  ),
                                  dropdownColor: Colors.white,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF7A8A94),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createCircle,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isLoading
                                    ? const [
                                  Color(0xFFB7C4CC),
                                  Color(0xFFB7C4CC),
                                ]
                                    : const [
                                  Color(0xFF2A8CFF),
                                  Color(0xFF43D17A),
                                ],
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                'Create Circle',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.black38,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.black45,
      ),
      filled: true,
      fillColor: const Color(0xFFF2F7F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF7BAE7F),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  final Widget child;

  const _PageBackground({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
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
            fit: StackFit.expand,
            clipBehavior: Clip.none,
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

              Positioned.fill(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C2A33),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8A94),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2A8CFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8A94),
                      ),
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

class _NoGroupsCard extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  const _NoGroupsCard({
    required this.onCreate,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            child: const Icon(
              Icons.groups_outlined,
              color: Color(0xFF2A8CFF),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You are not in any circle yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a new circle or join one to start completing challenges with friends.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFF7A8A94),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2A8CFF),
                      Color(0xFF43D17A),
                    ],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Create Circle',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: onJoin,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF2A8CFF),
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Join Circle',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2A8CFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> groupDoc;
  final IconData icon;
  final Color color;

  const _GroupCard({
    required this.groupDoc,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final data = groupDoc.data();

    final name = data['name']?.toString() ?? 'Unnamed circle';
    final theme = data['theme']?.toString() ?? '';
    final description = data['description']?.toString() ?? '';

    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupPageScreen(
                groupId: groupDoc.id,
              ),
            ),
          );
        },
        child: Container(
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
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C2A33),
                      ),
                    ),
                    if (theme.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        theme,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A94),
                        ),
                      ),
                    ],
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

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE5EEF5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2A8CFF),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C2A33),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
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
      padding: const EdgeInsets.all(22),
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