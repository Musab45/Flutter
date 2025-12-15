import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign In with Email and Password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up with Email and Password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign Out
  Future<void> signOut() async {
    debugPrint("Starting signout...");
    try {
      await _supabase.auth.signOut(scope: SignOutScope.global);
      debugPrint("Signout completed successfully");
    } catch (e) {
      debugPrint("Signout error: $e");
    }
  }

  // Get User Email
  String? getUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
