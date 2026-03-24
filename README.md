# Klima 🌦️

A premium, modern weather application built with **Flutter** and **Material Design 3 (Material You)**. Features a highly dynamic UI that adapts to the current weather condition and time of day, delivering a stunning and expressive experience.

> [!NOTE]
> 🤖 **Vibecoded**: Diese App wurde mit Hilfe von KI programmiert.

---

## ✨ Features

- **📍 Dynamic Theming**: Adapts to your wallpaper and current weather with smooth gradients.
- **🕒 Comprehensive Forecasts**: Get precise hour-by-hour updates and a detailed 7-day outlook.
- **🌡️ Expressive Hero Card**: Large, readable temperature display with "Feels Like" metrics and wind conditions.
- **🗺️ Interactive Map**: Real-time location marker with a built-in current temperature tag.
- **🌊 Immersive Animations**: Custom-painted wind (clouds) and rain animations that bring the weather to life.
- **⚙️ Deep Personalization**: Change temperature units (°C/°F), wind speed (km/h, m/s, mph), and application language.
- **🌗 Smart Night Mode**: Automatically transitions between light and dark themes based on local sunset times.
- **⚡ Performance & Caching**: Fast loading with shimmer effects and offline support via smart data caching.

---

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (v3.x)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider) (^6.1.0)
- **Theming**: [Dynamic Color](https://pub.dev/packages/dynamic_color) (Material You)
- **Fonts**: [Google Fonts (Outfit)](https://fonts.google.com/specimen/Outfit)
- **Networking**: [HTTP](https://pub.dev/packages/http)
- **Weather API**: [Open-Meteo](https://open-meteo.com/) (Free, No API Key Required)
- **Geocoding**: [Geolocator](https://pub.dev/packages/geolocator) & [Nominatim](https://nominatim.openstreetmap.org/)
- **WebView**: [WebView Flutter](https://pub.dev/packages/webview_flutter)

---

## 📦 Installation & Setup

1. **Prerequisites**: Ensure you have [Flutter installed](https://docs.flutter.dev/get-started/install) on your machine.
2. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/antigravity-weather.git
   cd antigravity-weather
   ```
3. **Get dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

### Running on Android
- Connect an Android device (USB Debugging enabled) or start an emulator.
- Ensure your Android SDK version is 21 or higher.
- Grant location permissions on the first launch for accurate local weather.

---

## 🛠 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | `^6.1.0` | Global state management |
| `geolocator` | `^13.0.1` | User location tracking |
| `dynamic_color` | `^1.7.0` | Material You dynamic theming |
| `google_fonts` | `^6.2.1` | Premium typography (Outfit) |
| `shared_preferences`| `^2.5.4` | Data caching & settings |
| `shimmer` | `^3.0.0` | Loading skeleton screens |
| `webview_flutter` | `^4.13.1` | Weather map display |

---

## 🤝 Credits

- **Weather Data**: Provided for free by [Open-Meteo](https://open-meteo.com) — thanks for the amazing open API!
- **Maps**: [OpenStreetMap](https://www.openstreetmap.org) and its community.
- **Icons**: Emoji and Material Symbols for a modern look.

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

---

*Made with ❤️ by Klima Team*
