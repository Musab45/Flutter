import 'package:flutter/material.dart';
import 'package:supabase_authentication/auth/auth_service.dart';
import 'package:supabase_authentication/screens/profile_page.dart';
import 'package:supabase_authentication/screens/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Login
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt login
    try {
      await authService.signInWithEmailPassword(email, password);
      //go to profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  label: Text('Email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  label: Text('Password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Login Button
              ElevatedButton(onPressed: login, child: Text('Login')),
              // Spacing
              SizedBox(height: 20),
              // To Sign Up Page
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Center(child: Text('Don\' have an account?')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
