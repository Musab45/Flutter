import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page_clean.dart';
import 'pages/details_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/not_found_page.dart';

/// A simple ChangeNotifier acting as an auth store for the demo.
class AuthNotifier extends ChangeNotifier {
  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
}

final auth = AuthNotifier();

/// App shell used for nested routes (ShellRoute example).
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('go_router Demo')),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (i) {
          if (i == 0) context.goNamed('home');
          if (i == 1) context.go('/settings');
        },
      ),
    );
  }
}

/// The top-level GoRouter instance used by the app.
final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: auth,
  redirect: (BuildContext context, GoRouterState state) {
    final loggedIn = auth.loggedIn;
    // use `location` for the current route (path + query)
    final loggingIn = state.location == '/login';
    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/details',
      name: 'details',
      builder: (context, state) => DetailsPage(id: state.queryParameters['id']),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // `/settings` is a parent route with nested sub-routes.
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
          routes: [
            GoRoute(
              // this becomes `/settings/account`
              path: 'account',
              name: 'settings_account',
              builder: (context, state) => const SettingsPage(title: 'Account'),
            ),
            GoRoute(
              // this becomes `/settings/security`
              path: 'security',
              name: 'settings_security',
              builder: (context, state) =>
                  const SettingsPage(title: 'Security'),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const SettingsPage(title: 'Profile'),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
