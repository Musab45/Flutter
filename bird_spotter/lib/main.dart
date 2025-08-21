import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:bird_spotter/screens/intro.dart';
import 'package:bird_spotter/screens/sign_in.dart';
import 'package:bird_spotter/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
          return MaterialApp(debugShowCheckedModeBanner: false, home: SignUp());
        },
      ),
    );
    ;
  }
}
