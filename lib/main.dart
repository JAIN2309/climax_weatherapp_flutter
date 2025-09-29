
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/core/theme.dart';
import 'src/modules/home/home_binding.dart';
import 'src/modules/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences and register with GetX before app start
  final prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs, permanent: true);

  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Weather Presentation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: HomeBinding(),
      home: const HomeView(),
    );
  }
}
