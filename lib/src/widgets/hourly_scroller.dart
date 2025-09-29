
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/weather_model.dart';
import '../core/utils.dart';

class HourlyScroller extends StatelessWidget {
  final HourlyWeather hourly;
  const HourlyScroller({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final count = hourly.timesUnix.length;
    final len = count < 24 ? count : 24;
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: len,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = hourly.timesUnix[i];
          final temp = hourly.temperatures[i];
          final precip = hourly.precipitation != null && hourly.precipitation!.length > i ? hourly.precipitation![i] : 0.0;
          final code = (hourly.weatherCodes != null && hourly.weatherCodes!.length > i) ? hourly.weatherCodes![i] : 0;
          final isNight = DateTime.fromMillisecondsSinceEpoch(t * 1000).toLocal().hour < 6 || DateTime.fromMillisecondsSinceEpoch(t * 1000).toLocal().hour >= 19;
          final asset = weatherCodeToAsset(code, isNight: isNight);
          return Container(
            width: 110,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formatHourShortFromUnix(t), style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                SvgPicture.asset(asset, width: 36, height: 36),
                const SizedBox(height: 8),
                Text('${temp.toStringAsFixed(0)}°', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${precip.toStringAsFixed(1)} mm', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
