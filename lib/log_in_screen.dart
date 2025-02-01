import 'package:care_loom_app/OTP_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'SignUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            String role = userDoc['role'];
            String name = userDoc['name'];
            List<dynamic> pairId = userDoc['pairId'] ?? [];


            bool isPhoneVerified = userDoc['isPhoneVerified'];
            if (!isPhoneVerified) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPAuthScreen(uid: userCredential.user!.uid),
                ),
              );
            } else {
              if (role == 'parent') {
                Navigator.pushReplacementNamed(context, '/parent');
    // , arguments:name
              } else if (role == 'child') {
                if (pairId[0] == "") {
                  Navigator.pushReplacementNamed(context, '/child-pairing');
                } else {

                  Navigator.pushReplacementNamed(context, '/child-home');
                }
              }
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message ?? 'Login failed. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _resetEmailController = TextEditingController();

        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to receive a password reset link.'),
              const SizedBox(height: 12),
              TextField(
                controller: _resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = _resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  _showErrorDialog('Please enter a valid email.');
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent. Check your inbox.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  _showErrorDialog(e.message ?? 'Failed to send reset email. Please try again.');
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // App Logo
                Image.asset(
                  'assets/care_loom_logo.png', // Use your logo here
                  height: 80, // Adjust the size as needed
                ),
                const SizedBox(height: 40),
                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );

                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
                // Smaller Lock Icon at the Bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Icon(
                      Icons.lock_outline,
                      size: 24, // Smaller lock icon
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

