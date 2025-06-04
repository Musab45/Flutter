import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer_app/providers/theme_provider.dart';
import 'package:musicplayer_app/widgets/neu_box.dart';
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
            padding: const EdgeInsets.fromLTRB(15, 25, 15, 25),
            child: NeuBox(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
        ],
      ),
    );
  }
}
