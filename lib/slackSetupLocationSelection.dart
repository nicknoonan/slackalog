import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SlackSetupLocationSelection extends StatefulWidget {
  final LatLng? initialLocation;

  const SlackSetupLocationSelection({super.key, this.initialLocation});

  @override
  State<SlackSetupLocationSelection> createState() => _SlackSetupLocationSelectionState();
}

class _SlackSetupLocationSelectionState extends State<SlackSetupLocationSelection> {
  final MapController _controller = MapController();
  LatLng? _picked;

  final LatLng _defaultCenter = LatLng(35.7683, -78.6520);
  final double _defaultZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _picked = widget.initialLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _controller.move(widget.initialLocation ?? _defaultCenter, widget.initialLocation != null ? 17.0 : _defaultZoom);
      } catch (_) {}
    });
  }

  void _onTap(_, LatLng latlng) {
    setState(() => _picked = latlng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select location'),
        actions: [
          if (_picked != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.of(context).pop<LatLng>(_picked),
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: widget.initialLocation ?? _defaultCenter,
          initialZoom: widget.initialLocation != null ? 17.0 : _defaultZoom,
          onTap: (tapPos, latlng) => _onTap(tapPos, latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.slackalog',
          ),
          if (_picked != null)
            MarkerLayer(
              markers: [
                    Marker(
                  point: _picked!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, size: 36, color: Colors.red),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            label: const Text('Use location'),
            icon: const Icon(Icons.check),
            onPressed: _picked != null ? () => Navigator.of(context).pop<LatLng>(_picked) : null,
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: null,
            child: const Icon(Icons.my_location),
            onPressed: () {
              try {
                _controller.move(_defaultCenter, _defaultZoom);
                setState(() => _picked = null);
              } catch (_) {}
            },
          ),
        ],
      ),
    );
  }
}
