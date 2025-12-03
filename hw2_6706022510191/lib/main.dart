import 'package:flutter/material.dart';

void main() {
  runApp(const Calculator());
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String display = "0";

  void onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        display = "0";
        return;
      }

      if (display == "0") {
        display = value;
      } else {
        display += value;
      }
    });
  }

  Widget buildButton(String label, {Color? color}) {
    return ElevatedButton(
      onPressed: () => onButtonPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[800],
        padding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 24)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Display
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
              child: Text(
                display,
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),

            // Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  buildButton("C", color: Colors.red), // ← NEW CLEAR BUTTON
                  buildButton("(", color: Colors.deepPurple),
                  buildButton(")", color: Colors.deepPurple),
                  buildButton("/", color: Colors.deepPurple),

                  buildButton("7"),
                  buildButton("8"),
                  buildButton("9"),
                  buildButton("*", color: Colors.deepPurple),

                  buildButton("4"),
                  buildButton("5"),
                  buildButton("6"),
                  buildButton("-", color: Colors.deepPurple),

                  buildButton("1"),
                  buildButton("2"),
                  buildButton("3"),
                  buildButton("+", color: Colors.deepPurple),

                  buildButton("0"),
                  buildButton("."),
                  buildButton("=", color: Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
