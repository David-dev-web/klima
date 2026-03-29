# Klima 🌦️ v1.0.0

[![Flutter](https://img.shields.io/badge/Flutter-v3.x-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Vibecoded](https://img.shields.io/badge/Built%20with-AI%20(Vibecoded)-orange.svg)](#vibecoded-philosophy)

**Klima** is a premium, open-source weather application designed for Android. It seamlessly blends high-precision meteorological data with a specialized **Material You** (Material Design 3) ecosystem, offering a highly personalized and visually expressive experience that adapts to your environment.

---

### 🌐 [**Visit Developer Portfolio**](https://david-dev-web.github.io/klima)

---

## 🎨 Features

- **📍 Dynamic Material You**: Native integration with Android's dynamic color system, mirroring your system wallpaper and weather conditions.
- **🕒 Precision Timeline**: High-fidelity hourly forecasts with a refined **temperature trend-line** and 7-day outlooks powered by the Open-Meteo API.
- **🌡️ Proportional Forecasts**: A unique 7-day view with relative temperature bars that visually represent the week's thermal spread.
- **🗺️ Interactive Map**: Embedded meteorological map views for real-time local context.
- **✨ Performance-Optimized UI**: Specialized rendering path (removed heavy BackdropFilters for buttery-smooth 60fps scrolling) and consistent emoji-based status icons.
- **💊 Info Pills**: A swipeable, high-density row of essential metrics like UV-Index, Sunrise/Sunset, Pressure, and Visibility.
- **⚙️ Advanced Personalization**: Global unit toggles (°C/°F, km/h, m/s, mph) and multi-language support (DE/EN).

---

## 📸 UI Screenshots

The current interface follows a minimalist "Nothing-inspired" aesthetic:
- **Hero Card**: Large temperature display with thin-weight typography and atmospheric overlays.
- **Hourly Scroll**: Horizontal cards joined by a fluid temperature curve.
- **Daily Forecast**: Grouped cards with consistent rounding (24dp) and color-coded temperature bars.

---

## 📂 Project Structure

- **lib/**: Core application logic and Material 3 UI widgets.
- **docs/**: [Personal Developer Portfolio](https://david-dev-web.github.io/klima) - A modern landing page showcasing projects and developer profile.
- **assets/**: App high-fidelity resources and iconography.

---

## ⚠️ Known Limitations

- **Android Only**: While the codebase is cross-platform, current build configuration and testing were strictly focused on **Android (SDK 21+)**. 
- **Home Screen Widget**: Native Android widgets are currently in research and not yet implemented.
- **No Web Support**: The web version (PWA) has been deprecated due to cross-origin resource sharing (CORS) limitations on the APIs used.

---

## 🤖 Vibecoded Philosophy

Klima is a product of the **Vibecoded** development philosophy. This means the application was architected, implemented, and polished using **state-of-the-art AI pair programming**. This approach allows for rapid iteration, consistent design patterns, and an uncompromising focus on user experience.

---

## 🛠️ Tech Stack

- **Core**: Flutter v3.x & Dart
- **State Management**: Provider (Centralized state for settings & data)
- **API**: Open-Meteo (High Precision, Free usage)
- **Design**: Material 3 / Google Fonts (Outfit)
- **Maps**: OpenStreetMap / Nominatim / Flutter Map
- **Caching**: SharedPreferences (Offline-first architecture)

---

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/David-dev-web/klima.git
   cd klima
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Build APK**:
   ```bash
   flutter build apk --release
   ```

*Note: Ensure your Android device/emulator has internet access and location services enabled for initial weather data lookup.*

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the animations, add new weather layers, or port the app to iOS, feel free to open a Pull Request.

---

## 📄 License

This project is licensed under the **MIT License**. For more information, please see the [LICENSE](LICENSE) file.

---

*Engineered with ❤️ by David-dev-web*
