import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String name;
  final String major;
  final String subject;
  final double work;
  final double mid;
  final double fin;
  final double total;
  final String grade;

  const ResultPage({
    super.key,
    required this.name,
    required this.major,
    required this.subject,
    required this.work,
    required this.mid,
    required this.fin,
    required this.total,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ผลการคำนวณ")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ชื่อ: $name"),
            Text("สาขา: $major"),
            Text("วิชา: $subject"),
            const Divider(),
            Text("คะแนนเก็บ: $work"),
            Text("กลางภาค: $mid"),
            Text("ปลายภาค: $fin"),
            const Divider(),
            Text("คะแนนรวม: $total"),
            
            Text(
              "เกรด: $grade",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("กลับหน้ากรอกข้อมูล"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
