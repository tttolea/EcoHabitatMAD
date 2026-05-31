import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../db/database_helper.dart';

class MapInspectionScreen extends StatelessWidget {
  const MapInspectionScreen({super.key});

  @override
  Widget build(BuildContext context) => const _MapInspectionContent();
}

class _MapInspectionContent extends StatefulWidget {
  const _MapInspectionContent();

  @override
  State<_MapInspectionContent> createState() => _MapInspectionContentState();
}

class _MapInspectionContentState extends State<_MapInspectionContent> {
  final MapController _spatialMapController = MapController();
  final TextEditingController _observationController = TextEditingController();

  List<Marker> _mapMarkers = [];
  List<Map<String, dynamic>> _manualObservations = [];
  String _dbStatusText = "Connecting to reserve database...";
  LatLng _currentLocation = const LatLng(40.389235, -3.627749); // Default fallback

  String _selectedCategory = "Air Quality Loss";
  final List<String> _climateCubeCategories = [
    "Air Quality Loss",
    "Noise Pollution Spikes",
    "Urban Heat Island",
    "Soil Sealing Deficit",
    "Loss of Local Habitat"
  ];

  @override
  void initState() {
    super.initState();
    _reloadTelemetryRecords();
    _determinePosition();
  }

  @override
  void dispose() {
    _spatialMapController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  // --- NEW LIVE GPS SENSOR INTEGRATION ---
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _dbStatusText = "Location services disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _dbStatusText = "Location permissions denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _dbStatusText = "Location permissions permanently denied.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapMarkers.add(
        Marker(
          point: _currentLocation,
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, size: 40, color: Colors.blue),
        ),
      );
    });

    _spatialMapController.move(_currentLocation, 15.5);
  }

  Future<void> _reloadTelemetryRecords() async {
    final databaseData = await DatabaseHelper.instance.getHistoryLogs();

    final filteredObservations = databaseData.where((log) {
      final conditionText = log['condition']?.toString() ?? '';
      return conditionText.contains('Observation:');
    }).toList();

    List<Marker> freshMarkers = [
      const Marker(
        point: LatLng(40.389235, -3.627749),
        width: 50,
        height: 50,
        child: Icon(Icons.business, size: 40, color: Colors.blueGrey),
      ),
    ];

    for (var log in filteredObservations) {
      if (log['latitude'] != null && log['longitude'] != null) {
        freshMarkers.add(
          Marker(
            point: LatLng(log['latitude'], log['longitude']),
            width: 45,
            height: 45,
            child: const Icon(Icons.assignment_turned_in, size: 35, color: Colors.teal),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _manualObservations = filteredObservations;
        _mapMarkers.addAll(freshMarkers);
        _dbStatusText = "Database Synced. Total Saved Field Notes: ${_manualObservations.length}";
      });
    }
  }

  Future<void> _submitManualObservation() async {
    if (_observationController.text.trim().isEmpty) return;

    final String structuredLogEntry =
        "[$_selectedCategory] Observation: ${_observationController.text.trim()}";

    await DatabaseHelper.instance.insertLog(
      _currentLocation.latitude,
      _currentLocation.longitude,
      structuredLogEntry,
    );

    _observationController.clear();
    if (mounted) FocusScope.of(context).unfocus();
    await _reloadTelemetryRecords();
  }

  void _zoomIn() {
    final currentZoom = _spatialMapController.camera.zoom;
    _spatialMapController.move(_spatialMapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _spatialMapController.camera.zoom;
    _spatialMapController.move(_spatialMapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _spatialMapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'es.upm.mad.ecohabitat',
                    ),
                    MarkerLayer(markers: _mapMarkers),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 15,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "zoom_in_btn",
                        backgroundColor: Colors.white,
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add, color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "zoom_out_btn",
                        backgroundColor: Colors.white,
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove, color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "center_location_btn",
                        backgroundColor: Colors.teal[800],
                        onPressed: _determinePosition,
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _dbStatusText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Log Objective Observation / Subjective Impression",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: _climateCubeCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _observationController,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Type qualitative notes here...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _submitManualObservation,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800]),
                          icon: const Icon(Icons.add_task, color: Colors.white, size: 16),
                          label: const Text("ADD TASK", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Field History Log Feed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        GestureDetector(
                          onTap: () async {
                            await DatabaseHelper.instance.clearLogs();
                            _reloadTelemetryRecords();
                          },
                          child: const Text("Clear Logs", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_manualObservations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("No manual logs recorded yet.", style: TextStyle(color: Colors.grey[400]))),
                      )
                    else
                      ..._manualObservations.map((logItem) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.grey[50],
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.sticky_note_2, color: Colors.teal),
                            title: Text(logItem['condition'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text("Point Coordinate: (${logItem['latitude']}, ${logItem['longitude']})", style: const TextStyle(fontSize: 11)),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}