
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/weather_api_client.dart';
import '../../data/weather_repository.dart';
import 'home_controller.dart';
import 'package:dio/dio.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(() => Dio());
    Get.lazyPut<WeatherApiClient>(() => WeatherApiClient(dio: Get.find<Dio>()));
    // SharedPreferences is already registered in main.dart
    Get.lazyPut<WeatherRepository>(() => WeatherRepository(apiClient: Get.find(), prefs: Get.find()));
    Get.lazyPut<HomeController>(() => HomeController(repo: Get.find()));
  }
}
