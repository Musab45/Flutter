import 'package:bird_spotter/providers/theme_provider.dart';
import 'package:bird_spotter/screens/sign_in.dart';
import 'package:bird_spotter/screens/sign_up.dart';
import 'package:bird_spotter/widgets/action_button.dart';
import 'package:bird_spotter/widgets/feature_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              context.watch<ThemeProvider>().backgroundGradient_1,
              context.watch<ThemeProvider>().backgroundGradient_2,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 100, 10, 30),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // top icon
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Center(
                      child: Icon(Icons.blur_on_rounded, size: 150),
                    ),
                  ),

                  // app name
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      'BirdSpotter',
                      style: context.watch<ThemeProvider>().heading,
                    ),
                  ),

                  // description
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                    child: Text(
                      'Your personal bird watching companion. Track sightings, learn about birds, and connect with nature.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // feature 1
                  FeatureCard(
                    heading: 'Track Sightings',
                    subHeading: 'Record when and where you spot birds',
                    icon: Icons.location_on_rounded,
                  ),

                  // feature 2
                  FeatureCard(
                    heading: 'Bird Library',
                    subHeading: 'Access information about hundreds of species',
                    icon: Icons.menu_book_rounded,
                  ),

                  // action button
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 120, 0, 0),
                    child: ActionButton(
                      text: 'Get Started',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                    ),
                  ),

                  // alternative text
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.watch<ThemeProvider>().accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
