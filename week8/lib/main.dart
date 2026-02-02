import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'List Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ---------------- DATA MODEL ----------------
class Data {
  late int id;
  late String name;
  late DateTime t;

  Data(this.id, this.name, this.t);
}

// ---------------- STATE ----------------
class _MyHomePageState extends State<MyHomePage> {
  String txt = "N/A";
  List<Data> myList = <Data>[];
  int img = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- SELECT ICON ----------
            Row(
              children: [
                Radio(
                  value: 1,
                  groupValue: img,
                  onChanged: (int? value) {
                    setState(() {
                      img = value!;
                    });
                  },
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/ig.png'),
                ),

                Radio(
                  value: 2,
                  groupValue: img,
                  onChanged: (int? value) {
                    setState(() {
                      img = value!;
                    });
                  },
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/line.png'),
                ),

                Radio(
                  value: 3,
                  groupValue: img,
                  onChanged: (int? value) {
                    setState(() {
                      img = value!;
                    });
                  },
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/rocket.png'),
                ),
              ],
            ),

            // ---------- ADD ITEM ----------
            ElevatedButton(
              onPressed: () {
                setState(() {
                  txt = "Add Item Success";
                  myList.add(Data(img, "1", DateTime.now()));
                });
              },
              child: const Text('Add Item'),
            ),

            // ---------- STATUS TEXT ----------
            Text(txt, textScaleFactor: 2),

            // ---------- LIST VIEW ----------
            SizedBox(
              width: double.infinity,
              height: 550,
              child: ListView.builder(
                itemCount: myList.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: ListTile(
                        leading: const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/images/rocket.png',
                          ),
                        ),
                        title: Text('Title Text (${myList[index].id})'),
                        subtitle: Text(myList[index].t.toString()),
                        trailing: const Icon(Icons.delete_rounded),
                        onTap: () {
                          setState(() {
                            txt = "Title Text ($index) is removed!";
                            myList.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
