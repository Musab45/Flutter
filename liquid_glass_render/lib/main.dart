// ignore_for_file: sort_child_properties_last, use_key_in_widget_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Liquid Glass Demo', home: MyGlassWidget());
  }
}

class MyGlassWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // This is the content that will be behind the glass
          Positioned.fill(
            child: Image.network(
              'https://w0.peakpx.com/wallpaper/915/96/HD-wallpaper-nature-3d-art-butterfly-green-tree-water.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // The LiquidGlass widget sits on top
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 60, 12, 24),
            child: Align(
              alignment: Alignment.center,
              child: LiquidGlass(
                settings: const LiquidGlassSettings(
                  thickness: 10,
                  glassColor: Color(0x1AFFFFFF),
                  lightIntensity: 1.5,
                  blend: 40,
                ),
                shape: LiquidRoundedSuperellipse(
                  borderRadius: Radius.circular(50),
                ),
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  'https://i1.sndcdn.com/artworks-6nxYqVnR1zgGoZa1-LzVTvw-t500x500.jpg',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                  child: Icon(
                                    Icons.phone_iphone,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // song
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Text(
                              'White Ferrari',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),

                        // author
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                            child: Text(
                              'Frank Ocean',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),

                        // controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                            Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
