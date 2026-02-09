import 'package:flutter/material.dart';

class ClCreate extends StatefulWidget {
  const ClCreate({Key? key}) : super(key: key);

  @override
  State<ClCreate> createState() => _ClCreateState();
}

class _ClCreateState extends State<ClCreate> {
  final yourName = TextEditingController();
  final surName = TextEditingController();
  final yourUni = TextEditingController();
  final yourFaculty = TextEditingController();

  @override
  void dispose() {
    yourName.dispose();
    surName.dispose();
    yourUni.dispose();
    yourFaculty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Create Form')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.insert_photo, size: 100),
              const SizedBox(height: 10),
              const Text(
                'General Info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              textFormF('Your Name', 'Input Your Name', yourName),
              const SizedBox(height: 10),
              textFormF('Surname', 'Input Your SurName', surName),
              const SizedBox(height: 10),
              const Text(
                'Education Info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              textFormF('Your University', 'Input Your University', yourUni),
              const SizedBox(height: 10),
              textFormF('Faculty', 'Input Your Faculty', yourFaculty),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('Your Name : ${yourName.text}');
                        debugPrint('Your SurName : ${surName.text}');
                        debugPrint('Your University : ${yourUni.text}');
                        debugPrint('Your Faculty : ${yourFaculty.text}');
                      },
                      child: const Text('Add Data'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField textFormF(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
