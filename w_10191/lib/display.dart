import 'package:flutter/material.dart';

class DisplayPage extends StatelessWidget {
  final int number;
  const DisplayPage({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    bool isEven = number % 2 == 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Display Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "ตัวเลขที่กรอก: $number",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              isEven ? "เป็นเลขคู่" : "เป็นเลขคี่",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Image.asset(
              isEven ? "images/pic2.jpg" : "images/pic1.jpg",
              width: 200,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
