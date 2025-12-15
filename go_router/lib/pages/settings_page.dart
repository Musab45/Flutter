import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final String title;
  const SettingsPage({this.title = 'Settings', super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text('This demonstrates nested/shell routes.'),
          ],
        ),
      ),
    );
  }
}
