
import 'package:get/get.dart';
import '../../data/weather_repository.dart';
import '../../data/models/weather_model.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends GetxController {
  final WeatherRepository repo;
  HomeController({required this.repo});

  final isLoading = false.obs;
  final weather = Rxn<WeatherResponse>();
  final locationName = ''.obs;
  final error = RxnString();
  final savedLocations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    reloadSavedLocations();
    fetchForSavedOrCurrent();
  }

  void reloadSavedLocations() {
    final list = repo.getSavedLocations();
    savedLocations.assignAll(list);
  }

  Future<void> fetchForSavedOrCurrent() async {
    if (savedLocations.isNotEmpty) {
      final first = savedLocations.first;
      final radius = first['radius_km'] as double?;
      await fetchWeather(first['lat'] as double, first['lon'] as double, name: first['name'] as String, radiusKm: radius);
      return;
    }
    await fetchWeatherFromGps();
  }

  Future<void> fetchWeatherFromGps() async {
    isLoading.value = true;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error.value = 'Location permission denied';
          isLoading.value = false;
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      await fetchWeather(pos.latitude, pos.longitude, name: 'Current Location');
    } catch (e) {
      error.value = 'Unable to get location: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeather(double lat, double lon, {String? name, double? radiusKm}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final cached = repo.getCachedWeather(lat: lat, lon: lon);
      if (cached != null) weather.value = cached;

      WeatherResponse fresh;
      if (radiusKm != null) {
        fresh = await repo.getWeatherForArea(lat: lat, lon: lon, radiusKm: radiusKm);
      } else {
        fresh = await repo.getWeather(lat: lat, lon: lon);
      }
      weather.value = fresh;
      locationName.value = name ?? '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    } catch (e) {
      error.value = 'Failed to fetch weather: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> geocode(String query) async {
    try {
      final res = await repo.apiClient.geocode(query);
      return res;
    } catch (e) {
      return [];
    }
  }

  Future<void> addSavedLocation(String name, double lat, double lon, {double? radiusKm}) async {
    await repo.saveLocation(name, lat, lon, radiusKm: radiusKm);
    reloadSavedLocations();
  }

  Future<void> removeSavedLocation(double lat, double lon) async {
    await repo.removeLocation(lat, lon);
    reloadSavedLocations();
  }
}
