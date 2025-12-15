import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('404', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('Page not found'),
          ],
        ),
      ),
    );
  }
}
