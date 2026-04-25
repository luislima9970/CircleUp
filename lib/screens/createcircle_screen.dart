import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'homepage_screen.dart';

class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _circleNameController = TextEditingController();

  String _selectedTheme = 'Sustainability';
  bool _isLoading = false;

  @override
  void dispose() {
    _circleNameController.dispose();
    super.dispose();
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
      await FirebaseFirestore.instance.collection('circles').add({
        'name': _circleNameController.text.trim(),
        'theme': _selectedTheme,
        'createdBy': user.uid,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Circle created successfully!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomepageScreen(),
        ),
      );
    } catch (e) {
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

  IconData _themeIcon() {
    if (_selectedTheme == 'Fitness') {
      return Icons.fitness_center_rounded;
    }

    if (_selectedTheme == 'Wellness') {
      return Icons.self_improvement_rounded;
    }

    return Icons.eco_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
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
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomepageScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Color(0xFF1C2A33),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

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
                            color: Colors.white.withOpacity(0.92),
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
                                    if (value == null ||
                                        value.trim().isEmpty) {
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
                                  'Theme',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F7F2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _themeIcon(),
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
                                    onPressed:
                                    _isLoading ? null : _createCircle,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      disabledBackgroundColor:
                                      Colors.transparent,
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
                                          child:
                                          CircularProgressIndicator(
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
              ),
            ],
          ),
        ),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomepageScreen(),
              ),
            );
          }

          if (index == 1) {
            return;
          }

          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tasks page will be available soon.'),
              ),
            );
          }

          if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile page will be available soon.'),
              ),
            );
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