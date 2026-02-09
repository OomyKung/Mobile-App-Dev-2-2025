import 'package:flutter/material.dart';
import 'dart:math' as math;

class CirclePage extends StatelessWidget {
  final double radius;

  const CirclePage({
    Key? key,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double area = math.pi * radius * radius;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Area'),
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
            Text('Radius: $radius'),
            const SizedBox(height: 20),
            Text('Area: $area'),
          ],
        ),
      ),
    );
  }
}
