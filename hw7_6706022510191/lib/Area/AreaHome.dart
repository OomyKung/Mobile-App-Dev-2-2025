import 'package:flutter/material.dart';
import 'rec.dart';
import 'tri.dart';
import 'cir.dart';

class AreaHome extends StatefulWidget {
  const AreaHome({Key? key}) : super(key: key);

  @override
  _AreaHomeState createState() => _AreaHomeState();
}

class _AreaHomeState extends State<AreaHome> {
  String selectedShape = 'Rectangle'; // Default shape

  // Controllers for text fields
  final heightController = TextEditingController();
  final widthController = TextEditingController();
  final baseController = TextEditingController();
  final radiusController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Function to validate if the input is a valid number
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null; // No error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geometric Area Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radio buttons to select shape
              RadioListTile<String>(
                title: const Text('Rectangle'),
                value: 'Rectangle',
                groupValue: selectedShape,
                onChanged: (value) {
                  setState(() {
                    selectedShape = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Triangle'),
                value: 'Triangle',
                groupValue: selectedShape,
                onChanged: (value) {
                  setState(() {
                    selectedShape = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Circle'),
                value: 'Circle',
                groupValue: selectedShape,
                onChanged: (value) {
                  setState(() {
                    selectedShape = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Conditional UI based on selected shape
              if (selectedShape == 'Rectangle') ...[
                TextFormField(
                  controller: widthController,
                  decoration: const InputDecoration(labelText: 'Width'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Height'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
              ],

              if (selectedShape == 'Triangle') ...[
                TextFormField(
                  controller: baseController,
                  decoration: const InputDecoration(labelText: 'Base'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(labelText: 'Height'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
              ],

              if (selectedShape == 'Circle') ...[
                TextFormField(
                  controller: radiusController,
                  decoration: const InputDecoration(labelText: 'Radius'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (selectedShape == 'Rectangle') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RectanglePage(
                            width: double.parse(widthController.text),
                            height: double.parse(heightController.text),
                          ),
                        ),
                      );
                    } else if (selectedShape == 'Triangle') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrianglePage(
                            base: double.parse(baseController.text),
                            height: double.parse(heightController.text),
                          ),
                        ),
                      );
                    } else if (selectedShape == 'Circle') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CirclePage(
                            radius: double.parse(radiusController.text),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Calculate Area'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    widthController.dispose();
    baseController.dispose();
    radiusController.dispose();
    super.dispose();
  }
}
