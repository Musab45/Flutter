import 'package:flutter/material.dart';
import '../routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                auth.login();
              },
              child: const Text('Simulate login'),
            ),
          ],
        ),
      ),
    );
  }
}
