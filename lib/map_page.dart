import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:slackalog/main.dart';
import 'package:slackalog/slackSetupRepository.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupDetailsPage.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialCenter;
  final double? initialZoom;

  const MapPage({super.key, this.initialCenter, this.initialZoom});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Initial center (example) — you can change to a better default later
  final LatLng _initialCenter = LatLng(35.7683, -78.6520); // San Francisco

  final double _initialZoom = 16.0;

  @override
  void initState() {
    super.initState();

    // If the page was given an initial center, move to it after the first frame
    if (widget.initialCenter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 120), () {
          try {
            _mapController.move(widget.initialCenter!, widget.initialZoom ?? _initialZoom);
          } catch (_) {}
        });
      });
    } else {
      // Ensure the default center is also applied to trigger tile fetch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 120), () {
          try {
            _mapController.move(_initialCenter, _initialZoom);
          } catch (_) {}
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _initialZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.slackalog',
              maxNativeZoom: 19,
            ),
            // Load slack setups from repository and show markers for those with coordinates
            FutureBuilder<SlackSetupModelList>(
              future: getIt<ISlackSetupRepository>().getSlackSetups(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return MarkerLayer(markers: const []);
                }

                final setups = snap.data!.list
                    .where((s) => s.latitude != null && s.longitude != null)
                    .toList();
                final markers = setups.map((s) {
                  final lat = s.latitude!;
                  final lon = s.longitude!;
                  return Marker(
                    point: LatLng(lat, lon),
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (sheetCtx) => Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text('${s.length}m'),
                                const SizedBox(height: 8),
                                Text(s.description),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(sheetCtx).pop(),
                                      child: const Text('Close'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (ctx) => SlackSetupDetailsPage(
                                            slackSetup: s,
                                            onDelete: (sl) async {
                                              await getIt<ISlackSetupRepository>().deleteSlackSetup(sl);
                                              setState(() {});
                                            },
                                          ),
                                        ));
                                      },
                                      child: const Text('Details'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList();

                return MarkerLayer(markers: markers);
              },
            ),
          ],
        ),
        Padding(
          padding: EdgeInsetsGeometry.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 15,
            children: [
              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.my_location),
                onPressed: () {
                  // Simple demo action: recenter map to initial center
                  _mapController.move(_initialCenter, _initialZoom);
                },
              ),
              FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
