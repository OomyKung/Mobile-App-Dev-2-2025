import 'package:flutter/material.dart';
import 'results.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  final TextEditingController d1 = TextEditingController();
  final TextEditingController d2 = TextEditingController();
  final TextEditingController d3 = TextEditingController();
  final TextEditingController money = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ซื้อเลขท้าย 3 ตัว'),backgroundColor: const Color.fromRGBO(255, 102, 188, 1),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                digitColumn("หลักร้อย",d1),
                digitColumn("หลักสิบ",d2),
                digitColumn("หลักหน่วย",d3),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: money,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'จำนวนเงินที่ต้องการซื้อ (บาท)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _buildButton(context)
          ],
        ),
      ),
    );
  }

  Widget digitColumn(String label, TextEditingController controller) {
  return Column(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      SizedBox(
        width: 60,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            counterText: '',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildButton(BuildContext context){
    return Center(child:ElevatedButton(
              onPressed: () {
                String buyNumber = d1.text + d2.text + d3.text;
                int buyMoney = int.parse(money.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      buyNumber: buyNumber,
                      buyMoney: buyMoney,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 80),
          backgroundColor: const Color.fromRGBO(255, 102, 188, 1),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 10,
        ),
        child: const Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Text(
              "ตรวจรางวัล",
              style:TextStyle(fontSize:22,fontWeight:FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(Icons.attach_money)])));
}
}