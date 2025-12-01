import 'package:flutter/material.dart';

void main() {
  runApp(OomyKung());
}

class OomyKung extends StatelessWidget {
  const OomyKung({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My App",
      home: MyHomePage(),
      theme: ThemeData(primarySwatch: Colors.cyan),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int number = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("1019-1 คุณานนท์ นาลินธมากร"))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "กดปุ่มเพื่อค่าตัวเลข",
              style: TextStyle(
                fontSize: 40,
                color: Color.fromARGB(255, 255, 102, 188),
              ),
            ),
            Text(
              number.toString(),
              style: TextStyle(
                fontSize: 60,
                color: Color.fromARGB(255, 255, 102, 188),
              ),
            ),
            Image(
              image: NetworkImage(
                "https://dep.go.th/media/showtime/storage/2024/11/06/4039/thumbnail/203621_0.jpg?1730891419",
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  number++;
                });
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
        /*child: Image(
          image: NetworkImage(
            "https://dep.go.th/media/showtime/storage/2024/11/06/4039/thumbnail/203621_0.jpg?1730891419",
          ),
        ),
        child: Text(
            "Hello! I'm Emu Otori!!",
            style: TextStyle(
              fontSize: 40,
              color: Color.fromARGB(255, 255, 102, 188),
            ),*/
      ),
    );
  }
}
