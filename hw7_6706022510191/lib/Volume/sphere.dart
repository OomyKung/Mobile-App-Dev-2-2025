import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpherePage extends StatelessWidget {
  final double radius;

  const SpherePage({
    Key? key,
    required this.radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double volume = (4/3) * math.pi * radius * radius * radius;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sphere Volume'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to home screen
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Radius: $radius"),
            const SizedBox(height: 20),
            Text('Volume: $volume'),
          ],
        ),
      ),
    );
  }
}
