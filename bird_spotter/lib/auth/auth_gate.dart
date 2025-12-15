import 'package:bird_spotter/screens/home.dart';
import 'package:bird_spotter/screens/intro.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: CircularProgressIndicator());
        }

        // checking if session id is valid
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return Home();
        } else {
          return Intro();
        }
      },
    );
  }
}
