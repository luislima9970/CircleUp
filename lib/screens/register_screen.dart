import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/screens/login_screen.dart';
import 'package:projesof/services/auth_service.dart';
import 'package:projesof/services/user_service.dart';
import 'package:projesof/widgets/background_circle.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService? authService;
  final UserService? userService;

  const RegisterScreen({
    super.key,
    this.authService,
    this.userService,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthService _authService;
  late final UserService _userService;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _userService = widget.userService ?? UserService();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      UserCredential userCredential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _userService.createUser(
        user: UserModel(id: userCredential.user?.uid, username: _usernameController.text.trim(), email: _emailController.text.trim())
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Error creating account.';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already being used.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating account: $e'),
        ),
      );
    }
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
                top: -80,
                right: -60,
                child: BackgroundCircle(
                  size: 190,
                  color: Color(0x332A8CFF),
                ),
              ),

              const Positioned(
                bottom: -90,
                left: -70,
                child: BackgroundCircle(
                  size: 220,
                  color: Color(0x3343D17A),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
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
                            height: 120,
                          ),
                        ),

                        const SizedBox(height: 26),

                        const Text(
                          'Create Account',
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
                          'Start your CircleUP journey and join your first circle.',
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
                                  'Username',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _usernameController,
                                  decoration: _inputDecoration(
                                    'Enter your username',
                                    Icons.badge_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter a username';
                                    }

                                    if (value.trim().length < 3) {
                                      return 'Username must be at least 3 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _inputDecoration(
                                    'Enter your email',
                                    Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter an email';
                                    }

                                    final emailRegex = RegExp(
                                      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    );

                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Please enter a valid email';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: _inputDecoration(
                                    'Enter your password',
                                    Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }

                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1C2A33),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirm,
                                  decoration: _inputDecoration(
                                    'Confirm your password',
                                    Icons.lock_clock_outlined,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirm = !_obscureConfirm;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 28),

                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _submit,
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
                                          'Create Account',
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

                                const SizedBox(height: 18),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Color(0xFF7A8A94),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Log In',
                                        style: TextStyle(
                                          color: Color(0xFF2A8CFF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
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