import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(OomyCW4());
}

class OomyCW4 extends StatelessWidget {
  const OomyCW4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "NEW CALCULATOR", home: OomyStateFul());
  }
}

class OomyStateFul extends StatefulWidget {
  const OomyStateFul({super.key});

  @override
  State<OomyStateFul> createState() => _OomyStateFulState();
}

class _OomyStateFulState extends State<OomyStateFul> {
  String num1 = "";
  String num2 = "";
  String operation = "";
  String display = "0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OOMY CALCULATOR - WEEK 4")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              display,
              style: const TextStyle(
                fontSize: 48,
                color: Color.fromRGBO(255, 102, 188, 1),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                calcBtn("7", () => pressNumber("7")),
                calcBtn("8", () => pressNumber("8")),
                calcBtn("9", () => pressNumber("9")),
                calcBtn("+", () => pressOperation("+")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                calcBtn("4", () => pressNumber("4")),
                calcBtn("5", () => pressNumber("5")),
                calcBtn("6", () => pressNumber("6")),
                calcBtn("-", () => pressOperation("-")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                calcBtn("1", () => pressNumber("1")),
                calcBtn("2", () => pressNumber("2")),
                calcBtn("3", () => pressNumber("3")),
                calcBtn("*", () => pressOperation("*")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                calcBtn("0", () => pressNumber("0")),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () => clear(),
                    child: const Text("C", style: TextStyle(fontSize: 22)),
                  ),
                ),
                calcBtn("=", () => calculate()),
                calcBtn("/", () => pressOperation("/")),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FloatingActionButton(
                    backgroundColor: Colors.orange,
                    onPressed: () => delete(),
                    child: const Text("DEL", style: TextStyle(fontSize: 22)),
                  ),
                ),
                calcBtn("%", () => pressOperation("%")),
                calcBtn("^", () => pressOperation("^")),
                calcBtn("√", () => pressOperation("√")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget calcBtn(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  void pressNumber(String number) {
    setState(() {
      if (operation.isEmpty) {
        num1 += number;
        display = num1;
      } else {
        num2 += number;
        display = num2;
      }
    });
  }

  void pressOperation(String op) {
    setState(() {
      operation = op;
    });
  }

  void clear() {
    setState(() {
      num1 = "";
      num2 = "";
      operation = "";
      display = "0";
    });
  }

  void calculate() {
    setState(() {
      double n1 = double.tryParse(num1) ?? 0;
      double n2 = double.tryParse(num2) ?? 0;
      double result = 0;

      switch (operation) {
        case "+":
          result = n1 + n2;
          break;
        case "-":
          result = n1 - n2;
          break;
        case "*":
          result = n1 * n2;
          break;
        case "/":
          if (n2 != 0) {
            result = n1 / n2;
          } else {
            display = "Error";
            return;
          }
        case "%":
          result = n2 * (n1 / 100);
          break;
        case "^":
          result = pow(n1, n2).toDouble();
          break;
        case "√":
          if (n1 >= 0) {
            result = sqrt(n1);
          } else {
            display = "Error";
            return;
          }
          break;
        default:
          return;
      }

      display = result.toString();
      num1 = display;
      num2 = "";
      operation = "";
    });
  }

  void delete() {
    setState(() {
      if (operation.isEmpty) {
        if (num1.isNotEmpty) {
          num1 = num1.substring(0, num1.length - 1);
          display = num1.isEmpty ? "0" : num1;
        }
      } else {
        if (num2.isNotEmpty) {
          num2 = num2.substring(0, num2.length - 1);
          display = num2.isEmpty ? "0" : num2;
        }
      }
    });
  }
}
