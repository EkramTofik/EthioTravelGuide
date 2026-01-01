import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

import 'package:flutter_application_1/authenticated_main.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  final int desiredTabIndex;

  const LoginPage({super.key, this.desiredTabIndex = 0});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _webClientId =
      '1056238909978-tu65oujnh6pi1uohh5s4742dp925vikr.apps.googleusercontent.com';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: _webClientId,
  );

  bool _isLoading = false;
  bool _isResetting = false;
  bool _passwordObscured = true;

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showInfo(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  void _goToApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            AuthenticatedMain(initialTabIndex: widget.desiredTabIndex),
      ),
      (route) => false,
    );
  }

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
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

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) await _ensureUserDoc(user);
      if (mounted) _goToApp();
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') message = 'No user found with this email';
      if (e.code == 'wrong-password') message = 'Incorrect password';
      if (e.code == 'invalid-email') message = 'Invalid email format';
      if (e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        message = 'Invalid email or password';
      }
      if (e.code == 'user-disabled') {
        message = 'This account is disabled';
      }
      _showError(message);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(provider);
        final user = cred.user;
        if (user != null) await _ensureUserDoc(user);
        if (mounted) _goToApp();
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

        final cred = await _auth.signInWithCredential(credential);
        final user = cred.user;
        if (user != null) await _ensureUserDoc(user);
        if (mounted) _goToApp();
      }
    } on FirebaseAuthException catch (e) {
      _showError('Google Sign-In failed: ${e.message ?? e.code}');
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendResetEmail() async {
    if (_isResetting) return;
    final email = _emailController.text.trim();
    if (email.isEmpty || !_looksLikeEmail(email)) {
      _showError('Enter a valid email to reset password');
      return;
    }
    setState(() => _isResetting = true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showInfo('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      String message = 'Could not send reset email';
      if (e.code == 'user-not-found') message = 'No user found with this email';
      if (e.code == 'invalid-email') message = 'Invalid email format';
      _showError(message);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B60B6),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your journey',
                  style: TextStyle(fontSize: 26, color: Color(0xFF30356E)),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EBFF),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B60B6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your credentials to access your account',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF30356E),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isBusy,
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: _passwordObscured,
                        enabled: !isBusy,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(fontSize: 18),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _passwordObscured = !_passwordObscured,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isBusy || _isResetting
                              ? null
                              : _sendResetEmail,
                          child: Text(
                            _isResetting ? 'Sending...' : 'Forgot Password?',
                            style: const TextStyle(
                              color: Color(0xFF30356E),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SignInButton(
                        Buttons.google,
                        text: 'Sign in with Google',
                        onPressed: () {
                          if (isBusy) return;
                          _signInWithGoogle();
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B60B6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                          child: isBusy
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: Color(0xFF30356E),
                              fontSize: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: isBusy
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF2B60B6),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
