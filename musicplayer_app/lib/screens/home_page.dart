import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicplayer_app/screens/settings_page.dart';

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
        child: Column(
          children: [
            DrawerHeader(child: Center(child: Icon(Icons.music_note_rounded))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
              child: ListTile(
                title: Text('SETTINGS', style: TextStyle(fontSize: 18)),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
