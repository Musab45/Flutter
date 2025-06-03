import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PLAYLIST')),
      drawer: Drawer(
        backgroundColor: Colors.white.withOpacity(0.3),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Column(),
          ),
        ),
      ),
    );
  }
}
