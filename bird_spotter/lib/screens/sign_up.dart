// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:bird_spotter/auth/auth_service.dart';
import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:bird_spotter/screens/home.dart';
import 'package:bird_spotter/screens/intro.dart';
import 'package:bird_spotter/screens/sign_in.dart';
import 'package:bird_spotter/widgets/action_button.dart';
import 'package:bird_spotter/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final authService = AuthService();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _confirmPasswordController = TextEditingController();

  // sign up
  Future<void> signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (confirmPassword != password) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match!')));
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Intro()),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 30),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              context.watch<ThemeProvider>().backgroundGradient_1,
              context.watch<ThemeProvider>().backgroundGradient_2,
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // heading
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 25),
                  child: Text(
                    'Create an account',
                    style: context.watch<ThemeProvider>().heading,
                  ),
                ),

                // email input
                InputField(
                  name: 'Email',
                  hint_text: 'your@email.com',
                  controller: _emailController,
                  hide_text: false,
                ),

                // spacing
                SizedBox(height: 10),

                // password input
                InputField(
                  name: 'Password',
                  hint_text: '* * * * * *',
                  controller: _passwordController,
                  hide_text: true,
                ),

                // spacing
                SizedBox(height: 10),

                // password input
                InputField(
                  name: 'Confirm Password',
                  hint_text: '* * * * * *',
                  controller: _confirmPasswordController,
                  hide_text: true,
                ),

                // action button
                Container(
                  margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: ActionButton(
                    text: 'Sign Up',
                    onPressed: () {
                      signUp();
                    },
                  ),
                ),

                // navigation to sign up
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Don\'t have an account?',
                      style: context.watch<ThemeProvider>().body,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Sign in',
                        style: context.watch<ThemeProvider>().body.copyWith(
                          color: context.watch<ThemeProvider>().accent,
                        ),
                      ),
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
