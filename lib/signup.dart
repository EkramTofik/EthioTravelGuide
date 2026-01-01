import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:flutter_application_1/authenticated_main.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const String _webClientId =
      '1056238909978-tu65oujnh6pi1uohh5s4742dp925vikr.apps.googleusercontent.com';

  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: _webClientId,
  );

  bool _isLoading = false;
  bool _passwordObscured = true;
  bool _confirmObscured = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter a password';
    if (password.length < 8) return 'Use at least 8 characters';
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));
    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Include upper, lower, number, and symbol';
    }
    return null;
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveUserDoc(
    User user,
  ) async {
    final col = FirebaseFirestore.instance.collection('user');
    final uidRef = col.doc(user.uid);

    final emailKey = user.email?.split('@').first;
    final emailRef = (emailKey != null && emailKey.isNotEmpty)
        ? col.doc(emailKey)
        : null;

    final displayKey = user.displayName
        ?.trim()
        .split(' ')
        .first
        .toLowerCase()
        .trim();
    final displayRef = (displayKey != null && displayKey.isNotEmpty)
        ? col.doc(displayKey)
        : null;

    for (final ref in [uidRef, emailRef, displayRef]) {
      if (ref == null) continue;
      final snap = await ref.get();
      if (snap.exists) return ref;
    }

    if (emailRef != null) return emailRef;
    if (displayRef != null) return displayRef;
    return uidRef;
  }

  Future<void> _ensureUserDoc(User user) async {
    final doc = await _resolveUserDoc(user);
    final snap = await doc.get();
    final existing = snap.data();

    final joinedAt = existing != null ? existing['joinedAt'] : null;
    final savedCount = (existing?['savedCount'] as num?)?.toInt() ?? 0;
    final ratedCount = (existing?['ratedCount'] as num?)?.toInt() ?? 0;

    await doc.set({
      'displayName':
          user.displayName ?? user.email?.split('@').first ?? 'Traveler',
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'joinedAt': joinedAt ?? FieldValue.serverTimestamp(),
      'savedCount': savedCount,
      'ratedCount': ratedCount,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      await user?.updateDisplayName(_fullNameController.text.trim());
      await user?.reload();

      if (user != null) {
        await _ensureUserDoc(user);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Welcome!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthenticatedMain(initialTabIndex: 0),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';
      if (e.code == 'weak-password') {
        message =
            'Password too weak. Use 8+ chars with upper, lower, number, symbol';
      }
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email';
      }
      if (e.code == 'invalid-email') message = 'Invalid email address';
      if (e.code == 'operation-not-allowed') {
        message = 'Email/password signup is disabled in Firebase';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      UserCredential cred;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        cred = await _auth.signInWithPopup(provider);
      } else {
        await _googleSignIn.signOut();
        final account = await _googleSignIn.signIn();
        if (account == null) {
          setState(() => _isLoading = false);
          return;
        }

        final auth = await account.authentication;
        if (auth.idToken == null) {
          throw Exception('Missing Google ID token');
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );

        cred = await _auth.signInWithCredential(credential);
      }

      final user = cred.user;
      if (user != null) {
        await _ensureUserDoc(user);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthenticatedMain(initialTabIndex: 0),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In failed: ${e.message ?? e.code}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const Text(
                'Join EthioTravel',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B60B6),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an account to start exploring',
                style: TextStyle(fontSize: 18, color: Color(0xFF30356E)),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EBFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B60B6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in your details to create an account',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF30356E),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        enabled: !isBusy,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isBusy,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isValidEmail(value.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        helperText:
                            '8+ chars with upper, lower, number, symbol',
                        obscure: _passwordObscured,
                        enabled: !isBusy,
                        suffix: IconButton(
                          icon: Icon(
                            _passwordObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _passwordObscured = !_passwordObscured,
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Reenter your password',
                        obscure: _confirmObscured,
                        enabled: !isBusy,
                        suffix: IconButton(
                          icon: Icon(
                            _confirmObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _confirmObscured = !_confirmObscured,
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
                      const SizedBox(height: 20),
                      SignInButton(
                        Buttons.google,
                        text: 'Sign up with Google',
                        onPressed: () {
                          if (isBusy) return;
                          _signUpWithGoogle();
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isBusy
                              ? null
                              : () {
                                  _createAccount();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B60B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isBusy
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Color(0xFF30356E)),
                          ),
                          GestureDetector(
                            onTap: isBusy
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF2B60B6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF30356E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            errorStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffix,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
