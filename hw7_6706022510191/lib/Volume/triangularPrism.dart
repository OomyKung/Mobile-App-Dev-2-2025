import 'package:flutter/material.dart';

class PrismPage extends StatelessWidget {
  final double base;
  final double triangleHeight;
  final double length;

  const PrismPage({
    Key? key,
    required this.base,
    required this.triangleHeight,
    required this.length,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double volume = 0.5 * base * triangleHeight * length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangular Prism Volume'),
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
            Text('Base: $base'),
            Text('Triangle Height: $triangleHeight'),
            Text("Length: $length"),
            const SizedBox(height: 20),
            Text('Volume: $volume'),
          ],
        ),
      ),
    );
  }
}
