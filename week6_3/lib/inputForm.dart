import 'package:flutter/material.dart';

enum ProductTypeEnum { deliverable, downloadable }

class FormValidatePage extends StatefulWidget {
  const FormValidatePage({Key? key}) : super(key: key);

  @override
  State<FormValidatePage> createState() => _FormValidatePageState();
}

class _FormValidatePageState extends State<FormValidatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescController = TextEditingController();

  bool _topProduct = false;
  ProductTypeEnum _productType = ProductTypeEnum.deliverable;
  String _productSize = "Large";

  @override
  void dispose() {
    _productNameController.dispose();
    _productDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DropDown")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "PRODUCT List to Form",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text("Add Product in the form"),

              const SizedBox(height: 20),

              /// Product Name (Validate)
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// Product Description (Validate)
              TextFormField(
                controller: _productDescController,
                decoration: const InputDecoration(
                  labelText: "Product Description",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter some text";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// Checkbox
              CheckboxListTile(
                title: const Text("Top Product New"),
                value: _topProduct,
                onChanged: (val) {
                  setState(() => _topProduct = val ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 10),

              /// Radio Buttons
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ProductTypeEnum>(
                      title: const Text("Deliverable"),
                      value: ProductTypeEnum.deliverable,
                      groupValue: _productType,
                      onChanged: (val) {
                        setState(() => _productType = val!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ProductTypeEnum>(
                      title: const Text("Downloadable"),
                      value: ProductTypeEnum.downloadable,
                      groupValue: _productType,
                      onChanged: (val) {
                        setState(() => _productType = val!);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Product Sizes",
                  prefixIcon: Icon(Icons.accessibility),
                  border: OutlineInputBorder(),
                ),
                value: _productSize,
                items: const [
                  DropdownMenuItem(value: "Small", child: Text("Small")),
                  DropdownMenuItem(value: "Medium", child: Text("Medium")),
                  DropdownMenuItem(value: "Large", child: Text("Large")),
                ],
                onChanged: (val) {
                  setState(() => _productSize = val!);
                },
              ),

              const SizedBox(height: 40),

              /// Submit Button
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  child: const Text("SUBMIT FORM"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processing Data")),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
