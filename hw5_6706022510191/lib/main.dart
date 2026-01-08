import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const OomyHomeWork5());
}

class OomyHomeWork5 extends StatelessWidget {
  const OomyHomeWork5({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oomy Week 6',
      themeMode: ThemeMode.system,
      home: Home(),
    );
  }
}
