
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/models/weather_model.dart';
import '../core/utils.dart';

class DailyList extends StatelessWidget {
  final DailyWeather daily;
  const DailyList({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    final n = daily.timesUnix.length;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: n,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final dayUnix = daily.timesUnix[i];
        final max = daily.tempMax[i];
        final min = daily.tempMin[i];
        final code = daily.weatherCodes[i];
        final isNight = DateTime.fromMillisecondsSinceEpoch(dayUnix * 1000).toLocal().hour < 6 || DateTime.fromMillisecondsSinceEpoch(dayUnix * 1000).toLocal().hour >= 19;
        final asset = weatherCodeToAsset(code, isNight: isNight);
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: SvgPicture.asset(asset, width: 36, height: 36),
            title: Text(formatDayFromUnix(dayUnix)),
            subtitle: Text('High ${max.toStringAsFixed(0)}° / Low ${min.toStringAsFixed(0)}°'),
            onTap: () {
              showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))), builder: (_) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatDayFromUnix(dayUnix), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(asset, width: 48, height: 48),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('High: ${max.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 16)),
                              Text('Low: ${min.toStringAsFixed(1)}°', style: const TextStyle(fontSize: 16)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Hourly snapshot (first 6 hours):', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // placeholder for hourly preview - in full app you could fetch hourly slice for that day
                      const Text('Hourly details will be implemented in extended version.'),
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')))
                    ],
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }
}
