import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  GoogleMapController? _mapController;
  bool _hasLocationPermission = false;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(14.039017, 101.367724),
    zoom: 7,
  );

  final Set<Marker> _markers = <Marker>{};

  Future<void> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    if (!_hasLocationPermission && mounted) {
      setState(() {
        _hasLocationPermission = true;
      });
    }
  }

  Future<Position> _determinePosition() async {
    await _ensureLocationPermission();

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final isRecent =
          DateTime.now().difference(lastKnown.timestamp) < const Duration(minutes: 2);
      if (isRecent && lastKnown.accuracy <= 50) {
        return lastKnown;
      }
    }

    final settings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
      timeLimit: const Duration(seconds: 20),
    );

    final current = await Geolocator.getCurrentPosition(locationSettings: settings);

    if (current.accuracy <= 50) {
      return current;
    }

    return Geolocator.getPositionStream(locationSettings: settings)
        .firstWhere((position) => position.accuracy <= 50)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => current,
        );
  }

  Future<void> _initLocationPermission() async {
    try {
      await _ensureLocationPermission();
    } catch (_) {
      // Permission can be requested later from the action button.
    }
  }

  @override
  void initState() {
    super.initState();
    _initLocationPermission();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final mapController = _mapController;
      if (mapController == null) return;

      final position = await _determinePosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 14),
        ),
      );

      if (!mounted) return;
      setState(() {
        _markers
          ..clear()
          ..add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: currentLatLng,
              infoWindow: const InfoWindow(title: 'Current Location'),
            ),
          );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location error: $e')));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Current Location')),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: _markers,
        myLocationEnabled: _hasLocationPermission,
        myLocationButtonEnabled: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCurrentLocation,
        label: const Text('Current Location'),
        icon: const Icon(Icons.location_history),
      ),
    );
  }
}
