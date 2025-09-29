
import 'weather_api_client.dart';
import 'models/weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class WeatherRepository {
  final WeatherApiClient apiClient;
  final SharedPreferences prefs;

  WeatherRepository({required this.apiClient, required this.prefs});

  Future<WeatherResponse> getWeather({required double lat, required double lon}) async {
    final resp = await apiClient.fetchWeather(latitude: lat, longitude: lon, timezone: 'auto');
    try {
      final json = _weatherToJson(resp);
      await prefs.setString('cached_weather_${lat}_${lon}', json);
      await prefs.setString('cached_weather_time_${lat}_${lon}', DateTime.now().toIso8601String());
    } catch (e) {
      // ignore caching errors
    }
    return resp;
  }

  /// Sample multiple points within radiusKm and return averaged weather
  Future<WeatherResponse> getWeatherForArea({
    required double lat,
    required double lon,
    required double radiusKm,
    int samples = 6,
  }) async {
    // include center
    final coords = <Map<String,double>>[];
    coords.add({'lat': lat, 'lon': lon});
    final R = 6371.0;
    for (int i=0;i<samples;i++) {
      final bearing = (2 * pi * i) / samples;
      final d = radiusKm * 0.6; // sample at ~60% of radius
      final lat1 = lat * pi / 180;
      final lon1 = lon * pi / 180;
      final brng = bearing;
      final lat2 = asin(sin(lat1)*cos(d/R) + cos(lat1)*sin(d/R)*cos(brng));
      final lon2 = lon1 + atan2(sin(brng)*sin(d/R)*cos(lat1), cos(d/R)-sin(lat1)*sin(lat2));
      coords.add({'lat': lat2 * 180 / pi, 'lon': lon2 * 180 / pi});
    }

    final responses = <WeatherResponse>[];
    for (final c in coords) {
      try {
        final r = await apiClient.fetchWeather(latitude: c['lat']!, longitude: c['lon']!, timezone: 'auto');
        responses.add(r);
      } catch (e) {
        // ignore failed sample
      }
    }

    if (responses.isEmpty) {
      // fallback to center single point
      return getWeather(lat: lat, lon: lon);
    }

    // Aggregate: assume hourly times align across responses
    final base = responses.first;
    final int hlen = base.hourly.timesUnix.length;
    final int dlen = base.daily.timesUnix.length;

    // sum arrays
    final hourlyTemps = List<double>.filled(hlen, 0.0);
    final hourlyPrecip = List<double>.filled(hlen, 0.0);
    final hourlyCodesCounts = List<List<int>>.generate(hlen, (_) => []);
    for (final r in responses) {
      if (r.hourly.temperatures.length == hlen) {
        for (int i=0;i<hlen;i++) {
          hourlyTemps[i] += r.hourly.temperatures[i];
          if (r.hourly.precipitation != null && r.hourly.precipitation!.length==hlen) hourlyPrecip[i] += r.hourly.precipitation![i];
          if (r.hourly.weatherCodes != null && r.hourly.weatherCodes!.length==hlen) hourlyCodesCounts[i].add(r.hourly.weatherCodes![i]);
        }
      }
    }
    final avgHourlyTemps = hourlyTemps.map((s) => s / responses.length).toList();
    final avgHourlyPrecip = hourlyPrecip.map((s) => s / responses.length).toList();
    final avgHourlyCodes = hourlyCodesCounts.map((lst) {
      if (lst.isEmpty) return 0;
      // majority vote
      final Map<int,int> freq={};
      for (final v in lst) freq[v]= (freq[v]??0)+1;
      int best=lst.first; int bestCount=0;
      freq.forEach((k,v){ if (v>bestCount){ best=k; bestCount=v; } });
      return best;
    }).toList();

    // daily aggregation
    final dailyMax = List<double>.filled(dlen, 0.0);
    final dailyMin = List<double>.filled(dlen, 0.0);
    final dailyCodesCounts = List<List<int>>.generate(dlen, (_) => []);
    for (final r in responses) {
      if (r.daily.tempMax.length == dlen) {
        for (int i=0;i<dlen;i++) {
          dailyMax[i] += r.daily.tempMax[i];
          dailyMin[i] += r.daily.tempMin[i];
          dailyCodesCounts[i].add(r.daily.weatherCodes[i]);
        }
      }
    }
    final avgDailyMax = dailyMax.map((s) => s / responses.length).toList();
    final avgDailyMin = dailyMin.map((s) => s / responses.length).toList();
    final avgDailyCodes = dailyCodesCounts.map((lst) {
      final Map<int,int> freq={};
      for (final v in lst) freq[v]= (freq[v]??0)+1;
      int best=lst.first; int bestCount=0;
      freq.forEach((k,v){ if (v>bestCount){ best=k; bestCount=v; } });
      return best;
    }).toList();

    // current aggregated temp and code (average temp, majority code)
    double curTempSum=0.0; Map<int,int> curCodeFreq={};
    for (final r in responses) {
      curTempSum += r.currentTemperature;
      curCodeFreq[r.currentWeatherCode] = (curCodeFreq[r.currentWeatherCode] ?? 0) + 1;
    }
    final avgCurTemp = curTempSum / responses.length;
    int majorityCurCode = curCodeFreq.keys.first;
    int bestCnt=0;
    curCodeFreq.forEach((k,v){ if (v>bestCnt){ majorityCurCode=k; bestCnt=v; } });

    return WeatherResponse(
      latitude: lat,
      longitude: lon,
      timezone: base.timezone,
      hourly: HourlyWeather(timesUnix: base.hourly.timesUnix, temperatures: avgHourlyTemps, precipitation: avgHourlyPrecip, weatherCodes: avgHourlyCodes),
      daily: DailyWeather(timesUnix: base.daily.timesUnix, tempMax: avgDailyMax, tempMin: avgDailyMin, weatherCodes: avgDailyCodes),
      currentTemperature: avgCurTemp,
      currentWeatherCode: majorityCurCode,
      currentTimeUnix: base.currentTimeUnix,
    );
  }

  WeatherResponse? getCachedWeather({required double lat, required double lon}) {
    final key = 'cached_weather_${lat}_${lon}';
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return null;
    try {
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      return _weatherFromJson(map);
    } catch (e) {
      return null;
    }
  }

  String _weatherToJson(WeatherResponse w) {
    final map = {
      'latitude': w.latitude,
      'longitude': w.longitude,
      'timezone': w.timezone,
      'currentTemperature': w.currentTemperature,
      'currentWeatherCode': w.currentWeatherCode,
      'currentTimeUnix': w.currentTimeUnix,
      'hourly': {
        'times': w.hourly.timesUnix,
        'temps': w.hourly.temperatures,
        'precip': w.hourly.precipitation,
        'codes': w.hourly.weatherCodes,
      },
      'daily': {
        'times': w.daily.timesUnix,
        'tmax': w.daily.tempMax,
        'tmin': w.daily.tempMin,
        'codes': w.daily.weatherCodes,
      },
    };
    return json.encode(map);
  }

  WeatherResponse _weatherFromJson(Map<String, dynamic> map) {
    final hourlyRaw = map['hourly'] as Map<String, dynamic>;
    final dailyRaw = map['daily'] as Map<String, dynamic>;
    return WeatherResponse(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timezone: map['timezone'] as String,
      currentTemperature: (map['currentTemperature'] as num).toDouble(),
      currentWeatherCode: (map['currentWeatherCode'] as num).toInt(),
      currentTimeUnix: (map['currentTimeUnix'] as num).toInt(),
      hourly: HourlyWeather(
        timesUnix: (hourlyRaw['times'] as List).map((e) => (e as num).toInt()).toList(),
        temperatures: (hourlyRaw['temps'] as List).map((e) => (e as num).toDouble()).toList(),
        precipitation: hourlyRaw['precip'] == null ? null : (hourlyRaw['precip'] as List).map((e) => (e as num).toDouble()).toList(),
        weatherCodes: hourlyRaw['codes'] == null ? null : (hourlyRaw['codes'] as List).map((e) => (e as num).toInt()).toList(),
      ),
      daily: DailyWeather(
        timesUnix: (dailyRaw['times'] as List).map((e) => (e as num).toInt()).toList(),
        tempMax: (dailyRaw['tmax'] as List).map((e) => (e as num).toDouble()).toList(),
        tempMin: (dailyRaw['tmin'] as List).map((e) => (e as num).toDouble()).toList(),
        weatherCodes: (dailyRaw['codes'] as List).map((e) => (e as num).toInt()).toList(),
      ),
    );
  }

  // Saved locations management (supports area radius)
  List<Map<String, dynamic>> getSavedLocations() {
    final raw = prefs.getString('saved_locations');
    if (raw == null) return [];
    try {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveLocation(String name, double lat, double lon, {double? radiusKm}) async {
    final list = getSavedLocations();
    list.removeWhere((e) => (e['lat'] == lat && e['lon'] == lon));
    final entry = {'name': name, 'lat': lat, 'lon': lon};
    if (radiusKm != null) entry['radius_km'] = radiusKm;
    list.insert(0, entry);
    await prefs.setString('saved_locations', json.encode(list));
  }

  Future<void> removeLocation(double lat, double lon) async {
    final list = getSavedLocations();
    list.removeWhere((e) => (e['lat'] == lat && e['lon'] == lon));
    await prefs.setString('saved_locations', json.encode(list));
  }
}
