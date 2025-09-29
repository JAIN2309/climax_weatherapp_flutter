
class HourlyWeather {
  final List<int> timesUnix;
  final List<double> temperatures;
  final List<double>? precipitation;
  final List<int>? weatherCodes;

  HourlyWeather({
    required this.timesUnix,
    required this.temperatures,
    this.precipitation,
    this.weatherCodes,
  });
}

class DailyWeather {
  final List<int> timesUnix;
  final List<double> tempMax;
  final List<double> tempMin;
  final List<int> weatherCodes;

  DailyWeather({
    required this.timesUnix,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCodes,
  });
}

class WeatherResponse {
  final double latitude;
  final double longitude;
  final String timezone;
  final HourlyWeather hourly;
  final DailyWeather daily;
  final double currentTemperature;
  final int currentWeatherCode;
  final int currentTimeUnix;

  WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.hourly,
    required this.daily,
    required this.currentTemperature,
    required this.currentWeatherCode,
    required this.currentTimeUnix,
  });
}
