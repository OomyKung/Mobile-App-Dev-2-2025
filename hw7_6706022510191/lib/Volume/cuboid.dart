import 'package:flutter/material.dart';

class CuboidPage extends StatelessWidget {
  final double length;
  final double height;
  final double width;

  const CuboidPage({
    Key? key,
    required this.length,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double volume = length * height * width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuboid Volume'),
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
            Text("Length: $length"),
            Text('Height: $height'),
            Text('Width: $width'),
            const SizedBox(height: 20),
            Text('Volume: $volume'),
          ],
        ),
      ),
    );
  }
}
