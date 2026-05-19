import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String phrase;

  const EditProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.phrase,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phraseController;

  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _phraseController = TextEditingController(text: widget.phrase);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phraseController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getInitial() {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      return '?';
    }

    return username[0].toUpperCase();
  }

  Future<void> _reauthenticate(User user) async {
    final currentPassword = _currentPasswordController.text.trim();

    if (user.email == null || user.email!.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'This account has no email.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _updateMemberDocuments({
    required String uid,
    required String username,
  }) async {
    try {
      final memberDocs = await FirebaseFirestore.instance
          .collectionGroup('members')
          .where('userId', isEqualTo: uid)
          .get();

      for (final memberDoc in memberDocs.docs) {
        await memberDoc.reference.set(
          {
            'username': username,
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Could not update member documents: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final username = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final phrase = _phraseController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final wantsToChangeEmail = newEmail != widget.email;
    final wantsToChangePassword = newPassword.isNotEmpty;

    if ((wantsToChangeEmail || wantsToChangePassword) &&
        currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your current password to change email or password.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (wantsToChangeEmail || wantsToChangePassword) {
        await _reauthenticate(user);
      }

      if (wantsToChangeEmail) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      if (wantsToChangePassword) {
        await user.updatePassword(newPassword);
      }

      await user.updateDisplayName(username);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'username': username,
          'email': newEmail,
          'profilePhrase': phrase,
        },
        SetOptions(merge: true),
      );

      await _updateMemberDocuments(
        uid: user.uid,
        username: username,
      );

      await user.reload();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String message = 'Could not update profile.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please log in again before changing email or password.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already being used.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        message = 'The new password is too weak.';
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      title: 'Edit Profile',
                      onBack: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 26),

                    Center(
                      child: Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getInitial(),
                            style: const TextStyle(
                              color: Color(0xFF2A8CFF),
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _EditProfileField(
                              controller: _usernameController,
                              label: 'Username',
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a username';
                                }

                                if (value.trim().length < 3) {
                                  return 'Username must have at least 3 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            _EditProfileField(
                              controller: _phraseController,
                              label: 'Profile phrase',
                              icon: Icons.format_quote_rounded,
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter a profile phrase';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            _EditProfileField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter an email';
                                }

                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            _EditProfileField(
                              controller: _currentPasswordController,
                              label: 'Current password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              helperText:
                              'Required only if you change email or password',
                            ),

                            const SizedBox(height: 16),

                            _EditProfileField(
                              controller: _newPasswordController,
                              label: 'New password',
                              icon: Icons.password_rounded,
                              obscureText: true,
                              helperText: 'Leave empty to keep current password',
                              validator: (value) {
                                if (value != null &&
                                    value.trim().isNotEmpty &&
                                    value.trim().length < 6) {
                                  return 'Password must have at least 6 characters';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            _EditProfileField(
                              controller: _confirmPasswordController,
                              label: 'Confirm new password',
                              icon: Icons.password_rounded,
                              obscureText: true,
                              validator: (value) {
                                final newPassword =
                                _newPasswordController.text.trim();

                                if (newPassword.isEmpty) {
                                  return null;
                                }

                                if (value == null || value.trim().isEmpty) {
                                  return 'Confirm your new password';
                                }

                                if (value.trim() != newPassword) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 26),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  elevation: 0,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _isSaving
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
                                      Radius.circular(18),
                                    ),
                                  ),
                                  child: Center(
                                    child: _isSaving
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                        : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
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

class _EditProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? helperText;
  final String? Function(String?)? validator;

  const _EditProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(
          icon,
          color: Colors.black45,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F7F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF2A8CFF),
            width: 2,
          ),
        ),
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