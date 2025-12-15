// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:bird_spotter/auth/auth_gate.dart';
import 'package:bird_spotter/constants/apiKey.dart';
import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  final _api = Apikey();
  await Supabase.initialize(anonKey: _api.supabase_api, url: _api.supabase_url);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ThemeProvider())],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: AuthGate(),
          );
        },
      ),
    );
  }
}
