import 'package:flutter/material.dart';
import 'cuboid.dart';
import 'sphere.dart';
import 'triangularPrism.dart';

class VolumeHome extends StatefulWidget {
  const VolumeHome({Key? key}) : super(key: key);

  @override
  State<VolumeHome> createState() => _VolumeHomeState();
}

class _VolumeHomeState extends State<VolumeHome> {
  String selectedShape = 'Cuboid';

  // Controllers
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final radiusController = TextEditingController();
  final baseController = TextEditingController();
  final triangleHeightController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Validator
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    radiusController.dispose();
    baseController.dispose();
    triangleHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volume Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------- Shape Selector ----------
              RadioListTile(
                title: const Text('Cuboid'),
                value: 'Cuboid',
                groupValue: selectedShape,
                onChanged: (v) => setState(() => selectedShape = v!),
              ),
              RadioListTile(
                title: const Text('Sphere'),
                value: 'Sphere',
                groupValue: selectedShape,
                onChanged: (v) => setState(() => selectedShape = v!),
              ),
              RadioListTile(
                title: const Text('Triangular Prism'),
                value: 'Triangular Prism',
                groupValue: selectedShape,
                onChanged: (v) => setState(() => selectedShape = v!),
              ),

              const SizedBox(height: 10),

              // ---------- Cuboid ----------
              if (selectedShape == 'Cuboid') ...[
                TextFormField(
                  controller: lengthController,
                  decoration: const InputDecoration(labelText: 'Length'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
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

              // ---------- Sphere ----------
              if (selectedShape == 'Sphere') ...[
                TextFormField(
                  controller: radiusController,
                  decoration: const InputDecoration(labelText: 'Radius'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
              ],

              // ---------- Triangular Prism ----------
              if (selectedShape == 'Triangular Prism') ...[
                TextFormField(
                  controller: baseController,
                  decoration: const InputDecoration(labelText: 'Base of triangle'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                TextFormField(
                  controller: triangleHeightController,
                  decoration: const InputDecoration(labelText: 'Height of triangle'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
                TextFormField(
                  controller: lengthController,
                  decoration: const InputDecoration(labelText: 'Length of prism'),
                  keyboardType: TextInputType.number,
                  validator: validateNumber,
                ),
              ],

              const SizedBox(height: 20),

              // ---------- Button ----------
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (selectedShape == 'Cuboid') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CuboidPage(
                            length: double.parse(lengthController.text),
                            width: double.parse(widthController.text),
                            height: double.parse(heightController.text),
                          ),
                        ),
                      );
                    } else if (selectedShape == 'Sphere') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpherePage(
                            radius: double.parse(radiusController.text),
                          ),
                        ),
                      );
                    } else if (selectedShape == 'Triangular Prism') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrismPage(
                            base: double.parse(baseController.text),
                            triangleHeight:
                                double.parse(triangleHeightController.text),
                            length: double.parse(lengthController.text),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Calculate Volume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
