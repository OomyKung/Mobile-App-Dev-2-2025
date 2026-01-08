import 'dart:math';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String buyNumber;
  final int buyMoney;

  const ResultPage({
    super.key,
    required this.buyNumber,
    required this.buyMoney,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    String resultNumber =
        random.nextInt(1000).toString().padLeft(3, '0');

    bool isWin = buyNumber == resultNumber;
    int reward = isWin ? buyMoney * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('ผลการตรวจรางวัล'),backgroundColor: const Color.fromRGBO(255, 102, 188, 1),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เลขที่คุณซื้อ คือ $buyNumber'),
            Text('จำนวนเงินที่คุณซื้อ คือ $buyMoney บาท'),
            const SizedBox(height: 10),
            Text('* เลขที่ออก คือ $resultNumber'),
            const SizedBox(height: 10),
            isWin
                ? Text('* ยินดีด้วยคุณถูกรางวัล\n* รับเงินรางวัล $reward บาท',
                    style: const TextStyle(color: Colors.green))
                : const Text('* เสียใจด้วย คุณไม่ถูกรางวัล',
                    style: TextStyle(color: Colors.red)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
              "กลับสู่หน้าหลัก",
              style:TextStyle(fontSize:22,fontWeight:FontWeight.bold),
              ),
                style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 80),
                backgroundColor: const Color.fromRGBO(255, 102, 188, 1),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 10,
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}
