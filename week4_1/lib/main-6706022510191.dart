import 'package:flutter/material.dart';
import 'foodMenu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  List<FoodMenu> menu = [
    FoodMenu("กุ้งเผา", "500", "assets/images/m1.jpg", "เผา"),
    FoodMenu("กระเพราหมู", "80", "assets/images/m2.jpg", "เผา"),
    FoodMenu("ข้าวผัด", "60", "assets/images/m3.jpg", "ต้ม"),
    FoodMenu("ผัดไท", "70", "assets/images/m4.jpg", "ต้ม"),
    FoodMenu("ต้มมะระ", "170", "assets/images/m5.jpg", "ต้ม"),
    FoodMenu("ปลาทอดกรอบ", "250", "assets/images/m6.jpg", "ทอด"),
    FoodMenu("ซาลาเปา", "50", "assets/images/m7.jpg", "ต้ม"),
    FoodMenu("แหนมเนือง", "70", "assets/images/m8.jpg", "ต้ม"),
    FoodMenu("ซูชิ", "70", "assets/images/m9.jpg", "ต้ม"),
    FoodMenu("บาร์บีคิว", "90", "assets/images/m10.jpg", "เผา"),
    FoodMenu("แฮมเบอร์เกอร์", "190", "assets/images/m11.jpg", "เผา"),
    FoodMenu("สปาเก็ตตี้", "120", "assets/images/m12.jpg", "ผัด"),
    FoodMenu("สลัดผัก", "70", "assets/images/m13.jpg", "ผัด"),
    FoodMenu("พิซซ่า", "300", "assets/images/m14.jpg", "เผา"),
    FoodMenu("ปาท่องโก๋", "40", "assets/images/m15.jpg", "ทอด"),
    FoodMenu("ข้าวต้ม", "50", "assets/images/m16.jpg", "ต้ม"),
    FoodMenu("ไข่กระทะ", "60", "assets/images/m17.jpg", "ทอด"),
    FoodMenu("โรตี", "70", "assets/images/m18.jpg", "ทอด"),
    FoodMenu("ขนมจีนน้ำยา", "80", "assets/images/m19.jpg", "ต้ม"),
    FoodMenu("น้ำผลไม้ปั่น", "90", "assets/images/m20.jpg", "ปั่น"),
  ];

  int _count = 0;
  String _lastSelected = '';
  int _totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (BuildContext context, int index) {
          FoodMenu food = menu[index];
          return ListTile(
            leading: Image.asset(
              food.img,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            title: Text(
              "${index + 1}" + ". " + food.name + '\nประเภท : ' + food.foodType,
              style: TextStyle(fontSize: 30),
            ),
            subtitle: Text(food.name + " ราคา" + food.price + " บาท"),
            onTap: () {
              final int price = int.tryParse(food.price) ?? 0;
              setState(() {
                _count += 1;
                _lastSelected = food.name;
                _totalPrice += price;
              });

              AlertDialog alert = AlertDialog(
                title: Text(_lastSelected),
                content: Text(
                  "เมนูล่าสุด: ${_lastSelected} \nคุณเลือกไป ${_count} จาน\nราคารวม ${_totalPrice} บาท",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ตกลง'),
                  ),
                ],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) => alert,
              );
            },
          );
        },
      ),
    );
  }
}
