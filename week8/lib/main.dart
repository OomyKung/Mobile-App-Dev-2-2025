import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'List Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// ---------- DATA MODEL ----------
class Data {
  int iconId;
  DateTime time;

  Data(this.iconId, this.time);
}

// ---------- STATE ----------
class _MyHomePageState extends State<MyHomePage> {
  String statusText = "N/A";
  List<Data> myList = [];
  int selectedIcon = 1;

  // Map icon id -> image path
  String getImagePath(int id) {
    switch (id) {
      case 1:
        return 'assets/images/ig.png';
      case 2:
        return 'assets/images/line.png';
      case 3:
        return 'assets/images/rocket.png';
      case 4:
        return 'assets/images/avengers.png';
      case 5:
        return 'assets/images/marvel.jpg';
      case 6:
        return 'assets/images/people.png';
      default:
        return 'assets/images/rocket.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ---------- RADIO SELECT ----------
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                _iconRadio(1, 'assets/images/ig.png'),
                _iconRadio(2, 'assets/images/line.png'),
                _iconRadio(3, 'assets/images/rocket.png'),
                _iconRadio(4, 'assets/images/avengers.png'),
                _iconRadio(5, 'assets/images/marvel.jpg'),
                _iconRadio(6, 'assets/images/people.png'),
              ],
            ),

            const SizedBox(height: 10),

            // ---------- ADD ITEM ----------
            ElevatedButton(
              onPressed: () {
                setState(() {
                  statusText = "Add Item Successful!";
                  myList.add(Data(selectedIcon, DateTime.now()));
                });
              },
              child: const Text('Add Item'),
            ),

            const SizedBox(height: 10),

            Text(statusText, textScaleFactor: 1.5),

            const SizedBox(height: 10),

            // ---------- LIST VIEW ----------
            SizedBox(
              height: 520,
              child: ListView.builder(
                itemCount: myList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                          getImagePath(myList[index].iconId),
                        ),
                      ),
                      title: Text('Item ${index + 1}'),
                      subtitle: Text(myList[index].time.toString()),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_rounded, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            statusText = "Deleted an item at index ${index+1}";
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

  // ---------- WIDGET: ICON RADIO ----------
  Widget _iconRadio(int value, String imagePath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<int>(
          value: value,
          groupValue: selectedIcon,
          onChanged: (v) {
            setState(() {
              selectedIcon = v!;
            });
          },
        ),
        CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(imagePath),
        ),
      ],
    );
  }
}
