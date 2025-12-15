import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Home', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Navigate with a query parameter
                  context.go('/details?id=42');
                },
                child: const Text('Go to Details (id=42)'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Use a direct location string with query param instead of named query params
                  context.go('/details?id=99');
                },
                child: const Text('Go to Details (id=99) using location'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/settings'),
                child: const Text('Open Settings (shell)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/settings/account'),
                child:
                    const Text('Open Settings → Account (/settings/account)'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/settings/security'),
                child:
                    const Text('Open Settings → Security (/settings/security)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (auth.loggedIn) {
                    auth.logout();
                  } else {
                    context.go('/login');
                  }
                },
                child: Text(auth.loggedIn ? 'Logout' : 'Login'),
              ),
              const SizedBox(height: 12),
              const Text('Deep-link examples:'),
              const SizedBox(height: 6),
              const Text('/details?id=123  -> details with query param'),
              const Text('/settings  -> shell route (bottom nav)'),
              const Text('/settings/account  -> nested settings route'),
              const Text('/login  -> login page (guard demo)'),
            ],
          ),
        ),
      ),
    );
  }
}
