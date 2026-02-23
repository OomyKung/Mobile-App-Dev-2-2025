import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  GoogleMapController? _mapController;

  // Replace this with your real home coordinates.
  static const LatLng _homeLatLng = LatLng(14.038980, 101.367745);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _homeLatLng,
    zoom: 12,
  );

  final Set<Marker> _markers = <Marker>{
    const Marker(
      markerId: MarkerId('my_home'),
      position: _homeLatLng,
      infoWindow: InfoWindow(title: 'My Home'),
    ),
  };

  Future<void> _goToMyHome() async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _homeLatLng, zoom: 16),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Home Location')),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        mapType: MapType.normal,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyHome,
        label: const Text('My Home'),
        icon: const Icon(Icons.home),
      ),
    );
  }
}
