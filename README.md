
Weather Presentation App v3 (GetX + Open-Meteo)
===============================================

This version includes:
- SVG icon pack and subtle animations (animated gradients)
- Area-mode aggregation: sample multiple points in an area and average weather
- Fixed layout issues and improved UI (Google Weather inspired)
- Uses Open-Meteo (no API key required)

How to run
----------
1. Unzip and open project folder.
2. Run `flutter pub get`
3. Add permissions (AndroidManifest / Info.plist) as required.
4. Run on a device: `flutter run`

Notes
-----
- The app samples 6 points around the center for area aggregation by default.
- SVG icons are in assets/icons/ and rendered with flutter_svg.
