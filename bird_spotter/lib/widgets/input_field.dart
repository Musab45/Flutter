// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputField extends StatefulWidget {
  String? name;
  String? hint_text;
  bool hide_text;
  TextEditingController controller;

  InputField({
    super.key,
    required this.name,
    required this.hint_text,
    required this.hide_text,
    required this.controller,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name ?? 'null',
          style: context.watch<ThemeProvider>().body.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
          child: TextFormField(
            obscureText: widget.hide_text,
            cursorColor: Colors.black,
            keyboardType: TextInputType.emailAddress,
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hint_text ?? 'null',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black26),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black26),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
