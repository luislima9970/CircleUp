import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projesof/app_state.dart';
import 'package:projesof/models/user_model.dart';
import 'package:projesof/services/user_service.dart';
import 'package:projesof/widgets/background_circle.dart';
import 'package:projesof/services/auth_service.dart';
import 'register_screen.dart';
import 'homepage_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginScreen({
    super.key,
    this.authService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _authService;
  late final UserService _userService;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      UserModel? user = await _userService.getUserById(_authService.getCurrentUid());
      AppState.setCurrentUser(user!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged in successfully!'),
        ),
      );



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomepageScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Error logging in.';

      if (e.code == 'user-not-found') {
        message = 'No user found with that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
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
          content: Text('Error logging in: $e'),
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
                          'Welcome Back',
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
                          'Log in to continue your CircleUP journey.',
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
                                      return 'Please enter your email';
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
                                      return 'Please enter your password';
                                    }

                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
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
                                          'Log In',
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
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: Color(0xFF7A8A94),
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                            const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Sign Up',
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