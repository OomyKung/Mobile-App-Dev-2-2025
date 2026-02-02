import 'package:flutter/material.dart';

class TrianglePage extends StatelessWidget {
  final double base;
  final double height;

  const TrianglePage({
    Key? key,
    required this.base,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double area = (base * height) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangle Area'),
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
            Text('Height: $height'),
            Text('Base: $base'),
            const SizedBox(height: 20),
            Text('Area: $area'),
          ],
        ),
      ),
    );
  }
}
