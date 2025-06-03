import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SETTINGS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).isDarkMode
                        ? Colors.grey[850]
                        : Colors.grey[400],
              ),
              child: Row(
                children: [
                  Text('DARK MODE'),
                  CupertinoSwitch(
                    value:
                        Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        ).isDarkMode,
                    onChanged:
                        (value) =>
                            Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleTheme(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
