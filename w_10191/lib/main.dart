import 'package:flutter/material.dart';
import 'form.dart';

void main() {
  runApp(const OomyCW6_2());
}

class OomyCW6_2 extends StatelessWidget {
  const OomyCW6_2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odd Even App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FormPage(),
    );
  }
}
