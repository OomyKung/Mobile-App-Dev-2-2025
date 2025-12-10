import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(OomyCW2());
}

//Type "st" for stateless widget shortcut
class OomyCW2 extends StatelessWidget {
  const OomyCW2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "MyApp", home: OomyStateFul());
  }
}

class OomyStateFul extends StatefulWidget {
  const OomyStateFul({super.key});

  @override
  State<OomyStateFul> createState() => _OomyStateFulState();
}

class _OomyStateFulState extends State<OomyStateFul> {
  int num = 0;
  String num1 = "";
  String num2 = "";
  String op = "";
  String display = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculator-Oomy")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(display.toString(), style: TextStyle(fontSize: 40)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "7";
                        display = num1;
                      } else {
                        num2 += "7";
                        display = num2;
                      }
                    });
                  },
                  child: Text("7"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "8";
                        display = num1;
                      } else {
                        num2 += "8";
                        display = num2;
                      }
                    });
                  },
                  child: Text("8"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "9";
                        display = num1;
                      } else {
                        num2 += "9";
                        display = num2;
                      }
                    });
                  },
                  child: Text("9"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "+";
                    });
                  },
                  child: Text("+"),
                ),
                SizedBox(width: 10),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "4";
                        display = num1;
                      } else {
                        num2 += "4";
                        display = num2;
                      }
                    });
                  },
                  child: Text("4"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "5";
                        display = num1;
                      } else {
                        num2 += "5";
                        display = num2;
                      }
                    });
                  },
                  child: Text("5"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "6";
                        display = num1;
                      } else {
                        num2 += "6";
                        display = num2;
                      }
                    });
                  },
                  child: Text("6"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "-";
                    });
                  },
                  child: Text("-"),
                ),
                SizedBox(width: 10),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "1";
                        display = num1;
                      } else {
                        num2 += "1";
                        display = num2;
                      }
                    });
                  },
                  child: Text("1"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "2";
                        display = num1;
                      } else {
                        num2 += "2";
                        display = num2;
                      }
                    });
                  },
                  child: Text("2"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "3";
                        display = num1;
                      } else {
                        num2 += "3";
                        display = num2;
                      }
                    });
                  },
                  child: Text("3"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "*";
                    });
                  },
                  child: Text("*"),
                ),
                SizedBox(width: 10),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (op.isEmpty) {
                        num1 += "0";
                        display = num1;
                      } else {
                        num2 += "0";
                        display = num2;
                      }
                    });
                  },
                  child: Text("0"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      num1 = "";
                      num2 = "";
                      display = "";
                      op = "";
                      num = 0;
                    });
                  },
                  child: Text("C"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (num1 == "" || num2 == "") return;
                      double n1 = double.parse(num1);
                      double n2 = double.parse(num2);
                      double result = 0;
                      if (op == "+") {
                        result = n1 + n2;
                      } else if (op == "-") {
                        result = n1 - n2;
                      } else if (op == "*") {
                        result = n1 * n2;
                      } else if (op == "/") {
                        result = n1 / n2;
                      } else if (op == "%") {
                        result = n2 * (n1 / 100);
                      } else if (op == "^") {
                        result = pow(n1, n2).toDouble();
                      }
                      display = result.toString();
                      num1 = display;
                      num2 = "";
                      op = "";
                    });
                  },
                  child: Text("="),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "/";
                    });
                  },
                  child: Text("/"),
                ),
                SizedBox(width: 10),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      display = display.substring(0, display.length - 1);
                    });
                  },
                  child: Text("DEL"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "%";
                    });
                  },
                  child: Text("%"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      op = "^";
                    });
                  },
                  child: Text("^"),
                ),
                SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      if (num1.isEmpty) return;
                      double n1 = double.parse(num1);
                      double result = sqrt(n1);
                      display = result.toString();
                      num1 = display;
                      num2 = "";
                      op = "";
                    });
                  },
                  child: Text("√"),
                ),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
