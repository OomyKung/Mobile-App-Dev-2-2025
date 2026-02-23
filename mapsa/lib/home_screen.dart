import 'package:flutter/material.dart';
import 'screens/simple_map_screen.dart';
import 'screens/current_location_screen.dart';
import 'screens/my_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Map New"), centerTitle: true),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MapSample()),
                );
              },
              child: const Text("Simple Map"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CurrentLocation(),
                  ),
                );
              },
              child: const Text("Current Location"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyHomeScreen(),
                  ),
                );
              },
              child: const Text("My Home"),
            ),
          ],
        ),
      ),
    );
  }
}
