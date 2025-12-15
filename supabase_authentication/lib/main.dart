// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:supabase_authentication/auth/auth_gate.dart';
import 'package:supabase_authentication/constants/apiKey.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final Apikey _api = Apikey();
  //setup for supabase
  await Supabase.initialize(anonKey: _api.supabase_api, url: _api.supabase_url);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Authentication',
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: AuthGate(),
    );
  }
}
