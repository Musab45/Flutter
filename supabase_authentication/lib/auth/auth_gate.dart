// listen for auth state changes
// unauthenticated --> login page
// authenticated --> profile page

import 'package:flutter/material.dart';
import 'package:supabase_authentication/screens/login_page.dart';
import 'package:supabase_authentication/screens/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // build page based on auth state
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // check if current session is valid
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return ProfilePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
