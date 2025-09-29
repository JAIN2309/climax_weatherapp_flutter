
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/weather_model.dart';
import '../core/utils.dart';
import 'animations.dart';

class CurrentWeatherCard extends StatefulWidget {
  final WeatherResponse weather;
  const CurrentWeatherCard({super.key, required this.weather});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final code = widget.weather.currentWeatherCode;
    final now = DateTime.now();
    final isNight = now.hour < 6 || now.hour >= 19;
    final asset = weatherCodeToAsset(code, isNight: isNight);
    final grad = gradientFor(code, isNight: isNight);
    final isRain = (code >= 51 && code <= 82) || (code >= 95 && code <= 99);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: grad, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Center(
                      child: SvgPicture.asset(asset, width: 88, height: 88),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.weather.currentTemperature.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Now — ${formatTimeFromUnix(widget.weather.currentTimeUnix)}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Lat: ${widget.weather.latitude.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(width: 12),
                            Text('Lon: ${widget.weather.longitude.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              // animation overlay
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.only(top: 6),
                child: CloudRainAnimation(rain: isRain, color: Colors.white54, height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
