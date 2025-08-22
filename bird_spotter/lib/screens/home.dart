import 'package:bird_spotter/auth/auth_service.dart';
import 'package:bird_spotter/screens/intro.dart';
import 'package:bird_spotter/screens/sign_in.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final authService = AuthService();

  // signout
  void signout() async {
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Intro()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            signout();
          },
          icon: Icon(Icons.login),
        ),
      ),
      body: Center(child: Text('Home Page')),
    );
  }
}
