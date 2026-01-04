import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupDeleteAlertDialog.dart';
import 'package:slackalog/slackSetupDetailsPageButtons.dart';
import 'package:slackalog/slackSetupCarousel.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupPage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

class SlackSetupDetailsPage extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final DeleteSlackSetupCallback onDelete;

  const SlackSetupDetailsPage({
    super.key,
    required this.slackSetup,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SlackSetupDeleteAlertDialog(
          onPressed: () async => await onDelete(slackSetup),
        );
      },
    );
  }

  void _gotoUpsertPage(BuildContext context, SlackSetupModel slackSetup) {
    // Use go_router to push the upsert route for this id
    context.push('/upsert/${slackSetup.id}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: slackSetup,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Details')),
          body: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Center(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // View-only carousel of setup images (tap any photo to open fullscreen)
                          ImageCarousel(
                            imagePaths: slackSetup.imagePaths,
                            height: 300,
                            heroTagPrefix: 'slack-${slackSetup.id}',
                            onImageTap: (index) {
                              if (index == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => ImageCarouselFullScreen(
                                    imagePaths: slackSetup.imagePaths,
                                    initialIndex: index,
                                    heroTagPrefix: 'slack-${slackSetup.id}',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slackSetup.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('${slackSetup.length}m'),
                          const SizedBox(height: 8),
                          Text(slackSetup.description),
                          const SizedBox(height: 12),
                          // Map preview (non-interactive) showing location when available
                          if (slackSetup.latitude != null &&
                              slackSetup.longitude != null) ...[
                            MapPreview(
                              lat: slackSetup.latitude!,
                              lon: slackSetup.longitude!,
                              onPressed: () {
                                // Navigate to the map route with query params to center the map
                                // Use go() to replace the location so the ShellRoute's location matches
                                context.go(
                                  '/map?lat=${slackSetup.latitude}&lon=${slackSetup.longitude}&zoom=17.0',
                                );

                                
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: SlackSetupDetailsPageButtons(
                      onDelete: () => _confirmDelete(context),
                      onEdit: () => _gotoUpsertPage(context, slackSetup),
                    ),
                  ),
                ],
              ), //
            ),
          ),
        );
      },
    );
  }
}

// A small, non-interactive map preview showing the given coordinates.
class MapPreview extends StatefulWidget {
  final double lat;
  final double lon;
  final double zoom;
  final VoidCallback onPressed;

  const MapPreview({
    super.key,
    required this.lat,
    required this.lon,
    this.zoom = 16.0,
    required this.onPressed,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Small delay helps ensure flutter_map internals are ready on all platforms
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          _mapController.move(LatLng(widget.lat, widget.lon), widget.zoom);
        } catch (_) {}
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        alignment: AlignmentGeometry.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AbsorbPointer(
              // AbsorbPointer disables taps/pan/zoom making the map view read-only
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.slackalog',
                    maxNativeZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.lat, widget.lon),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open in Map'),
            onPressed: widget.onPressed,
          ),
        ],
      ),
    );
  }
}
