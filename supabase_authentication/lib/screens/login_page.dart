// ignore_for_file: sort_child_properties_last

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: TextStyle(color: Colors.grey)),
            backgroundColor: Colors.transparent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[350],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  label: Text('Email', style: TextStyle(color: Colors.grey)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  label: Text('Password', style: TextStyle(color: Colors.grey)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Login Button
              ElevatedButton(
                onPressed: login,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.grey[350],
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
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
                child: Center(
                  child: Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
}
