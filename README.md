# 🌤️ Weather Presentation App v3

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter)
![Open-Meteo](https://img.shields.io/badge/API-Open--Meteo-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

A modern weather presentation app built with **Flutter** & **GetX**, inspired by **Google Weather**.  
It uses the free **[Open-Meteo API](https://open-meteo.com/)** (no API key required), supports **area-based weather aggregation**, and includes smooth **animations & SVG icons**.

---

## ✨ Features
- 📍 **Current location weather** (GPS support)
- ➕ **Save & manage multiple areas** (add/update/delete/sort)
- 🌍 **Area-mode aggregation** → samples 6 points around center and averages data  
- ⏱️ **Auto-refresh every 2 minutes** + manual **pull-to-refresh**
- ⏳ **Hourly forecast scrolling** with local device time
- 🎨 **Modern UI** with animated gradients, subtle cloud/rain animations, and SVG icon pack
- 💾 **Local caching** with `SharedPreferences` for fast reloads
- 🚀 Built using **GetX** for state management and clean architecture
- 
---

## 🛠️ Tech Stack
- **Flutter** (3.x+)
- **GetX** (State management + Dependency injection)
- **Dio/HTTP** (Networking)
- **SharedPreferences** (Local caching)
- **flutter_svg** (SVG weather icons)
- **Lottie / CustomPainter** (Smooth animations)
- **flutter_native_splash** & **flutter_launcher_icons** (App branding)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0)
- Android Studio / Xcode for device simulation
- A real device for GPS-based location testing

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/weather_presentation_app_v3.git

# Navigate into the project
cd weather_presentation_app_v3

# Install dependencies
flutter pub get

# Run with splash and icon setup
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create

# Launch app
flutter run
