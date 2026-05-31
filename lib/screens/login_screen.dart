import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true; // Toggles between Login and Sign Up

  Future<void> _submitAuthForm() async {
    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        // LOGIN LOGIC
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // REGISTRATION LOGIC
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created! Please log in.")),
        );
        setState(() => _isLoginMode = true); // Switch back to login mode
      }

      if (_isLoginMode && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabScreenNavigator()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.forest, size: 80, color: Colors.teal[800]),
              const SizedBox(height: 12),
              Text(
                _isLoginMode ? "ECOHABITAT LOGIN" : "ECOHABITAT SIGN UP",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.teal[900]),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitAuthForm,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800], padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isLoginMode ? "SIGN IN" : "REGISTER ACCOUNT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                        child: Text(_isLoginMode ? "Don't have an account? Register" : "Already have an account? Sign in"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}