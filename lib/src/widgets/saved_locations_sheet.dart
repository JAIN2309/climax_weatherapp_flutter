
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/home/home_controller.dart';
import '../../src/modules/home/home_view.dart' as hv;

class SavedLocationsSheet extends StatefulWidget {
  const SavedLocationsSheet({super.key});

  @override
  State<SavedLocationsSheet> createState() => _SavedLocationsSheetState();
}

class _SavedLocationsSheetState extends State<SavedLocationsSheet> {
  bool areaMode = false;
  final TextEditingController _radiusController = TextEditingController(text: '10');

  Future<Map<String, Object?>?> _showAddDialog(BuildContext context, {String? currentName, double? currentRadius}) async {
    final nameCtrl = TextEditingController(text: currentName ?? '');
    final radiusCtrl = TextEditingController(text: currentRadius?.toString() ?? '10');
    final result = await showDialog<Map<String, dynamic>?>(context: context, builder: (_) {
      return AlertDialog(
        title: Text(currentName == null ? 'Add location' : 'Edit location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: radiusCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Radius (km, optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop({'name': nameCtrl.text, 'radius': radiusCtrl.text}), child: const Text('Save')),
        ],
      );
    });
    if (result != null) {
      final name = result['name'] as String;
      final r = double.tryParse(result['radius'] as String? ?? '');
      // Use last searched coordinates? For simplicity, this dialog only edits name/radius.
      return {'name': name, 'radius': r};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saved Areas / Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add), onPressed: () async {
                  final result = await showSearch(context: context, delegate: hv.LocationSearchDelegate());
                  if (result != null && result is Map<String, dynamic>) {
                    final name = result['name'] ?? result['country'] ?? 'Location';
                    final lat = (result['latitude'] as num).toDouble();
                    final lon = (result['longitude'] as num).toDouble();
                    double? radius;
                    if (areaMode) {
                      final r = await showDialog<String?>(context: context, builder: (_) {
                        return AlertDialog(
                          title: const Text('Area radius (km)'),
                          content: TextField(controller: _radiusController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Radius in km')),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.of(context).pop(_radiusController.text), child: const Text('Save')),
                          ],
                        );
                      });
                      if (r != null) radius = double.tryParse(r);
                    }
                    await c.addSavedLocation(name, lat, lon, radiusKm: radius);
                  }
                })
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: areaMode, onChanged: (v) => setState(() => areaMode = v ?? false)),
                const SizedBox(width: 8),
                const Text('Save as area (radius in km)'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final list = c.savedLocations;
                if (list.isEmpty) return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('No saved locations yet. Use + to add.'),
                );
                return ReorderableListView.builder(
                  buildDefaultDragHandles: true,
                  itemCount: list.length,
                  onReorder: (oldIndex, newIndex) {
                    // simple reorder in preferences
                    final l = List<Map<String, dynamic>>.from(list);
                    final item = l.removeAt(oldIndex);
                    if (newIndex > oldIndex) newIndex -= 1;
                    l.insert(newIndex, item);
                    // save back to prefs by replacing all entries
                    // We can call repo.saveLocation for each, but simpler to set saved_locations directly
                    final prefs = c.repo.prefs;
                    prefs.setString('saved_locations', jsonEncode(l));
                    c.reloadSavedLocations();
                  },
                  itemBuilder: (context, i) {
                    final item = list[i];
                    final name = item['name'] ?? 'Location';
                    final lat = item['lat'];
                    final lon = item['lon'];
                    final radius = item['radius_km'];
                    return ListTile(
                      key: ValueKey('$lat,$lon'),
                      title: Text(name),
                      subtitle: Text('lat: $lat, lon: $lon${radius != null ? " • ${radius}km" : ""}'),
                      leading: const Icon(Icons.location_on),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                            final res = await _showAddDialog(context, currentName: name, currentRadius: radius as double?);
                            if (res != null) {
                              // update name and radius only
                              final newName = res['name'] as String;
                              final newRadius = res['radius'] as double?;
                              await c.removeSavedLocation(lat as double, lon as double);
                              await c.addSavedLocation(newName, lat as double, lon as double, radiusKm: newRadius);
                            }
                          }),
                          IconButton(icon: const Icon(Icons.open_in_new), onPressed: () async {
                            await c.fetchWeather(lat as double, lon as double, name: name as String, radiusKm: radius as double?);
                            Navigator.of(context).pop();
                          }),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                            await c.removeSavedLocation(lat as double, lon as double);
                          }),
                        ],
                      ),
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
