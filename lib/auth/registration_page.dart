import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'dart:async';

class RegistrationPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const RegistrationPage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController =
      TextEditingController(); // Controller for display name
  final _formKey = GlobalKey<FormState>();

  bool _isEmailValid = false;
  bool _isPasswordVisible = false;
  String _passwordStrengthMessage = "";
  Timer? _debounce;

  // Debounce for email validation
  void _onEmailChanged(String email) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isEmailValid = EmailValidator.validate(email);
      });
    });
  }

  // Password validation logic
  String _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isValidLength = password.length >= 8 && password.length <= 10;

    if (!isValidLength) {
      return 'Password must be 8-10 characters long';
    }
    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Password must contain upper, lower case letters, and numbers';
    }

    // Calculate password strength
    int strengthPoints = 0;
    if (hasUppercase) strengthPoints++;
    if (hasLowercase) strengthPoints++;
    if (hasDigits) strengthPoints++;
    if (hasSpecialChars) strengthPoints++;

    if (strengthPoints == 4) {
      return 'Password strength: Strong';
    } else if (strengthPoints == 3) {
      return 'Password strength: Medium';
    } else {
      return 'Password strength: Weak';
    }
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    final message = _validatePassword(password);
    setState(() {
      _passwordStrengthMessage = message;
    });
  }

  // Function to register a new user with email and password
  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final displayName = _displayNameController.text.trim();

      try {
        // Create user with email and password
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Set display name for the user
        await userCredential.user?.updateDisplayName(displayName);

        // Registration success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Registration Successful: ${userCredential.user?.email}')),
        );

        // Redirect to the next page or login page
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unknown error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 35.0),
                const Text(
                  "Welcome to GukGoo!\nLet's the fun begin!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),

                // Display Name TextFormField
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                    labelText: 'Enter your Display Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Display Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Email TextFormField with validation
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Enter your Email*',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onEmailChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!_isEmailValid) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_isEmailValid)
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email is valid!')),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Password TextFormField - shown only if email is valid
                if (_isEmailValid)
                  Column(
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outlined),
                          labelText: 'Enter your Password*',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) => _checkPasswordStrength(),
                        validator: (value) {
                          final passwordMessage =
                              _validatePassword(value ?? '');
                          if (passwordMessage.contains('Weak')) {
                            return 'Password is too weak';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15.0),

                      // Display password strength message
                      Text(
                        _passwordStrengthMessage,
                        style: TextStyle(
                          color: _passwordStrengthMessage.contains('Strong')
                              ? Colors.green
                              : _passwordStrengthMessage.contains('Medium')
                                  ? Colors.orange
                                  : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),

                // Register button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _registerUser(
                          context); // Call the registration function
                    },
                    child: const Text('Register'),
                  ),
                ),

                const SizedBox(height: 16.0),

                // Back to login option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }
}
