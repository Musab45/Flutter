# go_router demo

This small demo shows how to use `go_router` in a Flutter app.

Features included:
- Named routes
- Query parameters
- Redirects / simple auth guard
- ShellRoute (nested / bottom navigation)
- Unknown route (404)

How to run

1. Ensure Flutter is installed and in your PATH.
2. From the project root run:

```bash
cd /Users/musab/Documents/VSCode/Flutter/go_router
flutter pub get
flutter run
```

Examples to try inside the running app or via deep-links:
- `/details?id=123` — opens Details page with query param
- `/settings` — demonstrates ShellRoute (bottom navigation)
- `/login` — login screen invoked by the redirect/guard
