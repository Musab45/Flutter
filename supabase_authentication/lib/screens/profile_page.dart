import 'package:flutter/material.dart';
import 'package:supabase_authentication/auth/auth_service.dart';
import 'package:supabase_authentication/screens/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // initialize auth service
  final authService = AuthService();

  // signout
  void signout() async {
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(onPressed: signout, icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: Center(child: Text('Email: ${authService.getUserEmail()}')),
    );
  }
}
