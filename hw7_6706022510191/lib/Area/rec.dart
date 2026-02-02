import 'package:flutter/material.dart';

class RectanglePage extends StatelessWidget {
  final double height;
  final double width;

  const RectanglePage({
    Key? key,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double area = height * width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rectangle Area'),
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
            Text('Width: $width'),
            const SizedBox(height: 20),
            Text('Area: $area'),
          ],
        ),
      ),
    );
  }
}
