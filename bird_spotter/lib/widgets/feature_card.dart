// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class FeatureCard extends StatefulWidget {
  String? heading;
  String? subHeading;
  IconData? icon;

  FeatureCard({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.icon,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              color: Colors.blue.shade100,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(widget.icon, size: 40, color: Colors.blue),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.heading ?? 'null',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.subHeading ?? 'null',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
