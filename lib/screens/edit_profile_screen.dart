import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projesof/services/group_service.dart';
import 'package:projesof/services/image_upload_service.dart';
import 'package:projesof/services/user_service.dart';
import 'package:projesof/app_state.dart';

class EditProfileScreen extends StatefulWidget {

  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _phraseController;

  final TextEditingController _currentPasswordController =
  TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isSaving = false;

  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  File? _selectedImage;

  final user = AppState.currentUser!;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(text: user.username);
    _phraseController = TextEditingController(text: user.phrase);
  }

  @override
  void dispose() {
    _usernameController.dispose();
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

  ImageProvider? _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return NetworkImage(user.photoUrl!);
    }

    return null;
  }

  Future<void> _pickProfileImage() async {
    final image = await _imageUploadService.pickImageFromGallery();

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
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


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;

    final username = _usernameController.text.trim();
    final phrase = _phraseController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final wantsToChangePassword = newPassword.isNotEmpty;

    if (wantsToChangePassword && currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your current password to change password.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (wantsToChangePassword) {
        await _reauthenticate(firebaseUser!);
        await firebaseUser.updatePassword(newPassword);
      }

      String? uploadedPhotoUrl;

      if (_selectedImage != null) {
        uploadedPhotoUrl = await _imageUploadService.uploadProfileImage(
          imageFile: _selectedImage!,
          userId: user.id!,
        );

        if (uploadedPhotoUrl == null) {
          throw Exception('Could not upload profile image.');
        }

        await firebaseUser?.updatePhotoURL(uploadedPhotoUrl);
        await _userService.updatePhotoUrl(uid: user.id!, photoUrl: uploadedPhotoUrl);
      }

      await firebaseUser?.updateDisplayName(username);

      await _userService.updateUsername(uid: user.id!, username: username);


      await _groupService.updateMemberInfoInGroups(
          uid: user.id!,
          username: username,
          photoUrl: uploadedPhotoUrl,
          phrase: phrase);

      await firebaseUser!.reload();

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
        message = 'Please log in again before changing your password.';
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
    final avatarImage = _getAvatarImage();

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
                      subtitle: 'Update your personal details',
                      onBack: () => Navigator.pop(context),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 122,
                                  height: 122,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.96),
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 24,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xFFEAF4FF),
                                    backgroundImage: avatarImage,
                                    child: avatarImage == null
                                        ? Text(
                                      _getInitial(),
                                      style: const TextStyle(
                                        color: Color(0xFF2A8CFF),
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A8CFF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Profile information',
                            style: TextStyle(
                              color: Color(0xFF1C2A33),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap the avatar to change your photo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7A8A94),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _EditSectionCard(
                            title: 'Personal details',
                            icon: Icons.person_outline_rounded,
                            children: [
                              _EditProfileField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
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
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter a profile phrase';
                                  }

                                  if (value.trim().length > 90) {
                                    return 'Phrase must be shorter than 90 characters';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _EditSectionCard(
                            title: 'Security',
                            icon: Icons.lock_outline_rounded,
                            children: [
                              const _InfoBox(
                                text:
                                'Leave the password fields empty if you do not want to change your password.',
                              ),

                              const SizedBox(height: 16),

                              _EditProfileField(
                                controller: _currentPasswordController,
                                label: 'Current password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: true,
                                helperText:
                                'Required only when changing password',
                              ),

                              const SizedBox(height: 16),

                              _EditProfileField(
                                controller: _newPasswordController,
                                label: 'New password',
                                icon: Icons.password_rounded,
                                obscureText: true,
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

                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Confirm your new password';
                                  }

                                  if (value.trim() != newPassword) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
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

class _EditSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _EditSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

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
      child: Column(
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
                child: Icon(
                  icon,
                  color: const Color(0xFF2A8CFF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1C2A33),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;

  const _InfoBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: Color(0xFF43D17A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7A8A94),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1C2A33),
                ),
              ),
              const SizedBox(height: 3),
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