import 'package:flutter/material.dart';
import 'package:musicplayer_app/models/api.dart';
import 'package:musicplayer_app/providers/playlist_provider.dart';
import 'package:musicplayer_app/providers/theme_provider.dart';
import 'package:musicplayer_app/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  Api _api = Api();

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: _api.supabaseUrl, anonKey: _api.supabaseApi);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: HomePage(),
    );
  }
}

final supabase = Supabase.instance.client;
