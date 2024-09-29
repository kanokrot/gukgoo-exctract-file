import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class ForgetPasswordPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const ForgetPasswordPage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _isEmailValid = false;
      });
      return 'Please enter your email';
    }

    if (!EmailValidator.validate(value)) {
      setState(() {
        _isEmailValid = false;
      });
      return 'Please enter a valid email';
    }

    setState(() {
      _isEmailValid = true;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forget Password'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round),
            onPressed: widget.onThemeChanged,  // Theme toggle button
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60), // Move content up
            const Text(
              'Enter your email to reset your password',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center, 
            ),
            const SizedBox(height: 40), // Adjust spacing
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email TextFormField with Checkmark
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateEmail,
                        ),
                      ),
                      if (_isEmailValid) // Show checkmark if email is valid
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.check, color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Send Password Reset Email Button with Green Color
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set button color to green
                      minimumSize: const Size(double.infinity, 50), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // This is where you'd send the reset email
                        print("Password reset email sent");

                        // Optional: Show a confirmation message to the user
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent!'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Send Password Reset Email',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
