import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String? id;
  const DetailsPage({this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Details', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 12),
              Text('id: ${id ?? 'none'}'),
            ],
          ),
        ),
      ),
    );
  }
}
