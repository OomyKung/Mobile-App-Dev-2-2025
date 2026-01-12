import 'package:flutter/material.dart';
import 'inputForm.dart';

void main() {
  runApp(const OomyWeek6());
}

class OomyWeek6 extends StatelessWidget {
  const OomyWeek6({super.key});

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
