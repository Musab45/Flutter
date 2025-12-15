import 'package:concentric_transition/page_view.dart';
import 'package:concentric_transitions/home_page.dart';
import 'package:concentric_transitions/planet_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Transitions', home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final data = [
    CardPlanetData(
      title: 'CRYON',
      subtitle:
          'A cryogenic world locked in permanent sub-zero decay. Fractured ice fields reflect the last light of distant stars.',
      image: 'assets/images/planet_1.png',
      backgroundColor: Color(0xFF081A2A),
      titleColor: Color(0xFF6FD8FF),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
    CardPlanetData(
      title: 'VULKAR',
      subtitle:
          'Planetary crust failure exposes a living stellar core. Energy pressure increases with every orbital cycle.',
      image: 'assets/images/planet_2.png',
      backgroundColor: Color(0xFF90AB8B),
      titleColor: Color(0xFFCC561E),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
    CardPlanetData(
      title: 'NEBYRA',
      subtitle:
          'A planet suspended in charged plasma and ion storms. Matter exists here in constant energetic flux.',
      image: 'assets/images/planet_3.png',
      backgroundColor: Color(0xFF3D365C),
      titleColor: Color(0xFFD91656),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
    CardPlanetData(
      title: 'TERRA PRIME',
      subtitle:
          'A rare Class-M planet sustaining complex life systems. Atmospheric balance enables long-term civilization growth.',
      image: 'assets/images/planet_5.png',
      backgroundColor: Color(0xFF40A2E3),
      titleColor: Color(0xFFA0C878),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),

    CardPlanetData(
      title: 'PYROS',
      subtitle:
          'Surface fractures channel extreme thermal energy. Tectonic instability reshapes the planet in real time.',
      image: 'assets/images/planet_6.png',
      backgroundColor: Color(0xFF443627),
      titleColor: Color(0xFFFFC50F),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),

    CardPlanetData(
      title: 'AURELION',
      subtitle:
          'A massive gas giant encircled by high-velocity debris rings. Gravitational storms ripple endlessly through its atmosphere.',
      image: 'assets/images/planet_4.png',
      backgroundColor: Color(0xFF5A9CB5),
      titleColor: Color(0xFFF4631E),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
    CardPlanetData(
      title: 'MECHARA',
      subtitle:
          'A fully engineered planetary system controlled by AI cores. Mechanical logic governs climate, orbit, and energy flow.',
      image: 'assets/images/planet_7.png',
      backgroundColor: Color(0xFF0C141A),
      titleColor: Color(0xFF00FFD1),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),

    CardPlanetData(
      title: 'SOLARYN',
      subtitle:
          'A planet stabilized by a surrounding stellar energy ring. Excess solar power distorts nearby space-time.',
      image: 'assets/images/planet_9.png',
      backgroundColor: Color(0xFF80CBC4),
      titleColor: Color(0xFFFFD63A),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
    CardPlanetData(
      title: 'ABYSSIA',
      subtitle:
          'An oceanic planet with extreme depth pressure zones. Signals from below suggest unknown intelligent life.',
      image: 'assets/images/planet_8.png',
      backgroundColor: Color(0xFF020F1F),
      titleColor: Color(0xFF3FA9FF),
      subtitleColor: Colors.white,
      background: LottieBuilder.asset('assets/animations/animation_1.json'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        duration: Duration(milliseconds: 850),
        colors: data.map((e) => e.backgroundColor).toList(),
        itemCount: data.length,
        itemBuilder: (int index) {
          return PlanetCard(data: data[index]);
        },
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      ),
    );
  }
}
