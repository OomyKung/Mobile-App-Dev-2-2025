import 'package:flutter/material.dart';

void main() {
  runApp(const OomyHW4());
}

class OomyHW4 extends StatelessWidget {
  const OomyHW4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oomy HW4',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OomyHW4Stateful(),
    );
  }
}

class OomyHW4Stateful extends StatefulWidget {
  const OomyHW4Stateful({super.key});
  @override
  State<OomyHW4Stateful> createState() => _OomyHW4StatefulState();
}

class _OomyHW4StatefulState extends State<OomyHW4Stateful> {
  List<String> listData = [
    "เมนูที่ 1",
    "เมนูที่ 2",
    "เมนูที่ 3",
    "เมนูที่ 4",
    "เมนูที่ 5",
  ];
  void addMenu() {
    setState(() {
      listData.add("เมนูที่ ${listData.length + 1}");
    });
  }

  void removeMenu() {
    setState(() {
      if (listData.isNotEmpty) {
        listData.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Oomy HW4")),
      body: ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.menu),
              title: Text(listData[index]),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: addMenu,
            backgroundColor: Colors.green,
            child: Text("เพิ่ม"),
            tooltip: 'เพิ่มข้อมูล',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'remove',
            onPressed: removeMenu,
            backgroundColor: Colors.red,
            child: Text("ลบ"),
            tooltip: 'ลบข้อมูลล่าสุด',
          ),
        ],
      ),
    );
  }
}
