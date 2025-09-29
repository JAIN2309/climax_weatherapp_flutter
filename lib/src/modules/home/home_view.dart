
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../widgets/current_weather_card.dart';
import '../../widgets/hourly_scroller.dart';
import '../../widgets/daily_list.dart';
import '../../widgets/saved_locations_sheet.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            c.locationName.value.isEmpty ? 'Weather' : 'Weather — ${c.locationName.value}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(context: context, delegate: LocationSearchDelegate());
              if (result != null && result is Map<String, dynamic>) {
                final name = result['name'] ?? result['name_local'] ?? result['country'] ?? 'Search Location';
                final lat = (result['latitude'] as num).toDouble();
                final lon = (result['longitude'] as num).toDouble();
                await c.fetchWeather(lat, lon, name: '$name');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: const SavedLocationsSheet(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => c.fetchWeatherFromGps(),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.weather.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value != null) {
          return Center(child: Text('Error: ${c.error.value}'));
        }
        final w = c.weather.value;
        if (w == null) return const Center(child: Text('No data'));

        return RefreshIndicator(
          onRefresh: () async => await c.fetchWeather(w.latitude, w.longitude),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrentWeatherCard(weather: w),
                const SizedBox(height: 12),
                const Text('Hourly', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                HourlyScroller(hourly: w.hourly),
                const SizedBox(height: 12),
                const Text('7-day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DailyList(daily: w.daily),
                const SizedBox(height: 24),
                Center(child: Text('Last updated: ${DateTime.fromMillisecondsSinceEpoch(w.currentTimeUnix * 1000).toLocal()}')),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class LocationSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  LocationSearchDelegate() : super(searchFieldLabel: 'Search area or place');

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Get.find<HomeController>().geocode(query),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final items = snap.data ?? [];
        if (items.isEmpty) return const Center(child: Text('No results'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];
            final title = it['name'] ?? 'Unknown';
            final country = it['country'] ?? '';
            final admin = it['admin1'] ?? '';
            final lat = it['latitude'];
            final lon = it['longitude'];
            final type = it['feature_code'] ?? it['country_code'] ?? '';
            return ListTile(
              title: Text('$title, $admin, $country'),
              subtitle: Text('lat: $lat, lon: $lon ${type != null ? " • $type" : ""}'),
              onTap: () => close(context, it),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('Type an area or place name (e.g., "London", "Manhattan", "Bengaluru")')));
    return buildResults(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));
}
