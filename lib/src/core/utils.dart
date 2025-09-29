
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTimeFromUnix(int unix) {
  final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true).toLocal();
  return DateFormat.jm().format(dt); // e.g., 6:00 PM
}

String formatHourShortFromUnix(int unix) {
  final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true).toLocal();
  return DateFormat.Hm().format(dt); // 18:00
}

String formatDayFromUnix(int unix) {
  final dt = DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true).toLocal();
  return DateFormat.E().format(dt); // Mon, Tue...
}

/// Map Open-Meteo weather codes to local SVG asset names
String weatherCodeToAsset(int code, {bool isNight = false}) {
  if (code == 0) return isNight ? 'assets/icons/moon.svg' : 'assets/icons/sun.svg';
  if (code == 1 || code == 2 || code == 3) return 'assets/icons/cloud.svg';
  if (code >= 45 && code <= 48) return 'assets/icons/cloud.svg';
  if (code >= 51 && code <= 67) return 'assets/icons/rain.svg';
  if (code >= 71 && code <= 77) return 'assets/icons/snow.svg';
  if (code >= 80 && code <= 82) return 'assets/icons/rain.svg';
  if (code >= 85 && code <= 86) return 'assets/icons/snow.svg';
  if (code >= 95 && code <= 99) return 'assets/icons/storm.svg';
  return isNight ? 'assets/icons/moon.svg' : 'assets/icons/sun.svg';
}

/// Choose a gradient based on weather + time of day
List<Color> gradientFor(int weatherCode, {required bool isNight}) {
  if (isNight) return [Color(0xFF071126), Color(0xFF0B253C)];
  if (weatherCode == 0) return [Color(0xFFFFE29A), Color(0xFF56CCF2)];
  if (weatherCode >= 51 && weatherCode <= 82) return [Color(0xFF5D9CEC), Color(0xFF2F80ED)];
  if (weatherCode >= 71 && weatherCode <= 86) return [Color(0xFFB3E5FC), Color(0xFF6EC6FF)];
  if (weatherCode >= 95) return [Color(0xFF607D8B), Color(0xFF37474F)];
  return [Color(0xFF56CCF2), Color(0xFF2F80ED)];
}
