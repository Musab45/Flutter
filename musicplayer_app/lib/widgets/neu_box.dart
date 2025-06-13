// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer_app/providers/theme_provider.dart';

class NeuBox extends StatelessWidget {
  Widget? child;

  NeuBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            Provider.of<ThemeProvider>(context).isDarkMode
                ? Theme.of(context).scaffoldBackgroundColor
                : Color(0xFFd9d9d9),
        boxShadow: [
          // Dark shadow (bottom-right)
          Provider.of<ThemeProvider>(context).isDarkMode
              ? BoxShadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(6, 6),
                blurRadius: 10,
                spreadRadius: 0.8,
              )
              : BoxShadow(
                color: Colors.grey.shade500,
                offset: const Offset(6, 6),
                blurRadius: 10,
                spreadRadius: 0.8,
              ),
          // Light shadow (top-left)
          Provider.of<ThemeProvider>(context).isDarkMode
              ? BoxShadow(
                color: const Color(0xFF2a2a2a).withOpacity(0.7),
                offset: const Offset(-6, -6),
                blurRadius: 10,
                spreadRadius: 0.8,
              )
              : BoxShadow(
                color: Color(0xFFd9d9d9),
                offset: const Offset(-6, -6),
                blurRadius: 10,
                spreadRadius: 0.8,
              ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(8.0), child: child),
    );
  }
}
