
import 'package:dio/dio.dart';
import 'models/weather_model.dart';

class WeatherApiClient {
  final Dio _dio;

  WeatherApiClient({Dio? dio}) : _dio = dio ?? Dio();

  Future<WeatherResponse> fetchWeather({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
  }) async {
    final url = 'https://api.open-meteo.com/v1/forecast';
    final params = {
      'latitude': latitude,
      'longitude': longitude,
      'hourly': 'temperature_2m,precipitation,weathercode',
      'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
      'current_weather': true,
      'timezone': timezone,
    };
    final resp = await _dio.get(url, queryParameters: params);
    final data = resp.data;
    final hourly = data['hourly'] as Map<String, dynamic>;
    final hourlyTimes = (hourly['time'] as List).map((t) => DateTime.parse(t).toUtc().millisecondsSinceEpoch ~/ 1000).toList();
    final temps = (hourly['temperature_2m'] as List).map((t) => (t as num).toDouble()).toList();
    List<double>? precip;
    if (hourly.containsKey('precipitation')) {
      precip = (hourly['precipitation'] as List).map((p) => (p as num).toDouble()).toList();
    }
    List<int>? hourlyCodes;
    if (hourly.containsKey('weathercode')) {
      hourlyCodes = (hourly['weathercode'] as List).map((c) => (c as num).toInt()).toList();
    }

    final daily = data['daily'] as Map<String, dynamic>;
    final dailyTimes = (daily['time'] as List).map((t) => DateTime.parse(t).toUtc().millisecondsSinceEpoch ~/ 1000).toList();
    final tmax = (daily['temperature_2m_max'] as List).map((n) => (n as num).toDouble()).toList();
    final tmin = (daily['temperature_2m_min'] as List).map((n) => (n as num).toDouble()).toList();
    final weathercodes = (daily['weathercode'] as List).map((c) => (c as num).toInt()).toList();

    final current = data['current_weather'] as Map<String, dynamic>;
    final currentTemp = (current['temperature'] as num).toDouble();
    final currentCode = (current['weathercode'] as num).toInt();
    final currentTimeStr = current['time'] as String;
    final currentUnix = DateTime.parse(currentTimeStr).toUtc().millisecondsSinceEpoch ~/ 1000;

    return WeatherResponse(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      timezone: data['timezone'] as String,
      hourly: HourlyWeather(
        timesUnix: hourlyTimes.cast<int>(),
        temperatures: temps,
        precipitation: precip,
        weatherCodes: hourlyCodes,
      ),
      daily: DailyWeather(
        timesUnix: dailyTimes.cast<int>(),
        tempMax: tmax,
        tempMin: tmin,
        weatherCodes: weathercodes,
      ),
      currentTemperature: currentTemp,
      currentWeatherCode: currentCode,
      currentTimeUnix: currentUnix,
    );
  }

  Future<List<Map<String, dynamic>>> geocode(String query) async {
    final url = 'https://geocoding-api.open-meteo.com/v1/search';
    final resp = await _dio.get(url, queryParameters: {'name': query, 'count': 20});
    final data = resp.data as Map<String, dynamic>;
    if (!data.containsKey('results')) return [];
    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    return results;
  }
}
