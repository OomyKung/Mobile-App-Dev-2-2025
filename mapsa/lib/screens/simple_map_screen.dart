import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController;

  static const CameraPosition _googlePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  static const CameraPosition _lake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  Future<void> _goToTheLake() async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_lake));
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TEST MAP')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _googlePlex,
        buildingsEnabled: false,
        indoorViewEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
