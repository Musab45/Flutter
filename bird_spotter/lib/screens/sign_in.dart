import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:bird_spotter/screens/intro.dart';
import 'package:bird_spotter/screens/sign_up.dart';
import 'package:bird_spotter/widgets/action_button.dart';
import 'package:bird_spotter/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

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
                    'Welcome Back',
                    style: context.watch<ThemeProvider>().heading,
                  ),
                ),

                // email input
                InputField(
                  name: 'Email',
                  hint_text: 'your@email.com',
                  controller: emailController,
                  hide_text: false,
                ),

                // spacing
                SizedBox(height: 10),

                // password input
                InputField(
                  name: 'Password',
                  hint_text: '* * * * * *',
                  controller: passwordController,
                  hide_text: true,
                ),

                // action button
                Container(
                  margin: EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: ActionButton(text: 'Sign In', onPressed: () {}),
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
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Sign up',
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
