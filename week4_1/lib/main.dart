import 'package:flutter/material.dart';
import 'MoneyBox.dart';

void main() {
  runApp(const MyApp());
}

class InputDecoratorExample extends StatelessWidget {
  const InputDecoratorExample({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: "Account Name",
        labelStyle: MaterialStateTextStyle.resolveWith((
          Set<MaterialState> states,
        ) {
          final Color color = states.contains(MaterialState.error)
              ? Theme.of(context).colorScheme.error
              : Colors.orange;
          return TextStyle(color: color, letterSpacing: 1.3);
        }),
      ),
      validator: (String? value) {
        if (value == null || value == '') {
          return 'Enter name';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.always,
    );
  }
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              height: 120,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InputDecoratorExample(),
            ),
            MoneyBox(
              "ยอดคงเหลือ",
              30000.512,
              120,
              Color.fromRGBO(255, 102, 188, 1),
            ),
            MoneyBox("รายรับ", 10000, 120, Colors.blueAccent),
            MoneyBox("รายจ่าย", 80000, 120, Colors.greenAccent),
            MoneyBox("ค้างจ่าย", 4000, 120, Colors.orangeAccent),
            Container(
              child: TextButton(
                child: Text(
                  "Button",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                style: TextButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
