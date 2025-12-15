# 🌌 Concentric Transitions

A mesmerizing Flutter app showcasing stunning concentric page transitions through a cosmic journey across unique planets. Explore cryogenic worlds, volcanic cores, plasma clouds, and more with smooth, animated transitions.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## ✨ Features

- **Concentric Page Transitions**: Smooth, animated transitions between planet views
- **9 Unique Planets**: Each with distinct themes, colors, and descriptions
- **Cosmic Aesthetics**: Deep space colors and neon accents
- **Responsive Design**: Optimized for mobile devices
- **Lottie Animations**: Integrated animation support for enhanced visuals

## 🚀 Planets Showcase

| Planet | Theme | Description |
|--------|-------|-------------|
| **CRYON** | Ice Shard Planet | Cryogenic world with fractured ice fields |
| **VULKAR** | Cracked Core Planet | Exposed stellar core with increasing energy pressure |
| **NEBYRA** | Plasma Cloud Planet | Charged plasma and ion storms |
| **AURELION** | Ringed Gas Giant | Massive gas giant with debris rings |
| **TERRA PRIME** | Earth-Like World | Rare Class-M planet sustaining life |
| **PYROS** | Molten Rift Planet | Extreme thermal energy and tectonic activity |
| **MECHARA** | Artificial Core Planet | AI-controlled engineered system |
| **ABYSSIA** | Ocean World | Oceanic planet with extreme depths |
| **SOLARYN** | Stellar Energy World | Stabilized by stellar energy rings |

## 📱 Screenshots

*Add screenshots of your app here*

## 🛠️ Installation

1. **Prerequisites**
   - Flutter SDK (3.9.0 or higher)
   - Dart SDK
   - Android Studio / VS Code with Flutter extensions

2. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/concentric_transitions.git
   cd concentric_transitions
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- `flutter`: The Flutter framework
- `concentric_transition`: For concentric page transitions
- `lottie`: For Lottie animations
- `cupertino_icons`: iOS style icons

## 🏗️ Project Structure

```
lib/
├── main.dart          # Main app entry point with planet data
├── planet_card.dart    # Planet card widget
└── home_page.dart      # Home page after transitions

assets/
├── images/            # Planet images (planet_1.png to planet_9.png)
└── animations/        # Lottie animation files
```

## 🎨 Customization

### Adding New Planets

1. Add planet data to the `data` list in `main.dart`
2. Include corresponding image in `assets/images/`
3. Update `pubspec.yaml` assets if needed

### Color Themes

Each planet has customizable:
- Background color
- Title color
- Subtitle color (default: white)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 🙏 Acknowledgments

- [Concentric Transition Package](https://pub.dev/packages/concentric_transition)
- [Lottie for Flutter](https://pub.dev/packages/lottie)
- Flutter community for amazing documentation

---

**Made with ❤️ using Flutter**
