import 'package:flutter/material.dart';
import 'result.dart';

enum MajorEnum { INE, INET }

class FormValidatePage extends StatefulWidget {
  const FormValidatePage({Key? key}) : super(key: key);

  @override
  State<FormValidatePage> createState() => _FormValidatePageState();
}

class _FormValidatePageState extends State<FormValidatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController workController = TextEditingController();
  final TextEditingController midController = TextEditingController();
  final TextEditingController finalController = TextEditingController();

  MajorEnum major = MajorEnum.INE;
  String subject = "Network Design and Implementation";

  @override
  void dispose() {
    nameController.dispose();
    workController.dispose();
    midController.dispose();
    finalController.dispose();
    super.dispose();
  }

  String? scoreValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "กรุณากรอกคะแนน";
    }
    final score = double.tryParse(value);
    if (score == null) {
      return "ต้องเป็นตัวเลข";
    }
    if (score < 0 || score > 100) {
      return "คะแนนต้องอยู่ระหว่าง 0 - 100";
    }
    return null;
  }

  void calculateGrade() {
    if (!_formKey.currentState!.validate()) return;

    double work = double.parse(workController.text);
    double mid = double.parse(midController.text);
    double fin = double.parse(finalController.text);

    double total = work + mid + fin;
    String grade;

    if (total >= 80) {
      grade = "A";
    } else if (total >= 70) {
      grade = "B";
    } else if (total >= 60) {
      grade = "C";
    } else if (total >= 50) {
      grade = "D";
    } else {
      grade = "F";
    }

    Navigator.push(context,MaterialPageRoute(
        builder: (context) => ResultPage(
          name: nameController.text,
          major: major.name,
          subject: subject,
          work: work,
          mid: mid,
          fin: fin,
          total: total,
          grade: grade,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GradeApp")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Application คำนวณเกรด",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              /// ชื่อ - นามสกุล
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อ - นามสกุล",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                        ? "กรุณากรอกชื่อ - นามสกุล"
                        : null,
              ),

              const SizedBox(height: 20),

              /// Radio สาขา
              const Text("สาขาวิชา"),
              RadioListTile<MajorEnum>(
                title: const Text("INE"),
                value: MajorEnum.INE,
                groupValue: major,
                onChanged: (val) {
                  setState(() => major = val!);
                },
              ),
              RadioListTile<MajorEnum>(
                title: const Text("INET"),
                value: MajorEnum.INET,
                groupValue: major,
                onChanged: (val) {
                  setState(() => major = val!);
                },
              ),

              const SizedBox(height: 20),

              /// Dropdown วิชา
              DropdownButtonFormField<String>(
                value: subject,
                decoration: const InputDecoration(
                  labelText: "รหัสวิชา",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Computer Programming", child: Text("Computer Programming")),
                  DropdownMenuItem(value: "Intro to INE", child: Text("Intro to INE")),
                  DropdownMenuItem(value: "Data Communications and Computer Network", child: Text("Data Communications and Computer Network")),
                  DropdownMenuItem(value: "Network Design and Implementation", child: Text("Network Design and Implementation")),
                ],
                onChanged: (val) {
                  setState(() => subject = val!);
                },
              ),

              const SizedBox(height: 20),

              /// คะแนน
              TextFormField(
                controller: workController,
                keyboardType: TextInputType.number,
                validator: scoreValidator,
                decoration: const InputDecoration(
                  labelText: "คะแนนเก็บ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: midController,
                keyboardType: TextInputType.number,
                validator: scoreValidator,
                decoration: const InputDecoration(
                  labelText: "กลางภาค",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: finalController,
                keyboardType: TextInputType.number,
                validator: scoreValidator,
                decoration: const InputDecoration(
                  labelText: "ปลายภาค",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              /// ปุ่มคำนวณ
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  onPressed: calculateGrade,
                  child: const Text("คำนวณเกรด"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
