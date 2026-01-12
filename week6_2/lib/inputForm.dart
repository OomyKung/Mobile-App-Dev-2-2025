import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'my_text_field.dart';
import 'Shopping.dart';
import 'my_radio_button.dart';

enum ProductTypeEnum { Downloadable, Deliverable, OnShop, Reserver }

class MyForm extends StatefulWidget {
  const MyForm({Key? key}) : super(key: key);

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _productController = TextEditingController();
  final _productDesController = TextEditingController();

  bool? _listTileCheckBox = false;

  ProductTypeEnum? _productTypeEnum;

  @override
  void dispose() {
    _productController.dispose();
    _productDesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PRODUCT")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text("PRODUCT App", style: TextStyle(fontSize: 30)),
            const Text("Add Product detail in the form"),

            const SizedBox(height: 10),
            MyTextField(
              fieldName: "Product Name",
              myController: _productController,
              myIcon: Icons.fire_truck,
            ),

            const SizedBox(height: 20),
            MyTextField(
              fieldName: "Product Description",
              myController: _productDesController,
              myIcon: Icons.description,
            ),

            /// CheckboxListTile
            CheckboxListTile(
              title: const Text("Top Product"),
              value: _listTileCheckBox,
              onChanged: (val) {
                setState(() => _listTileCheckBox = val);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            /// Radio Button (Template)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyRadioButton(
                  title: ProductTypeEnum.Deliverable.name,
                  value: ProductTypeEnum.Deliverable,
                  selectedProductType: _productTypeEnum,
                  onChanged: (val) {
                    setState(() => _productTypeEnum = val);
                  },
                ),
                const SizedBox(height: 8),
                MyRadioButton(
                  title: ProductTypeEnum.Downloadable.name,
                  value: ProductTypeEnum.Downloadable,
                  selectedProductType: _productTypeEnum,
                  onChanged: (val) {
                    setState(() => _productTypeEnum = val);
                  },
                ),
                const SizedBox(height: 8),
                MyRadioButton(
                  title: ProductTypeEnum.OnShop.name,
                  value: ProductTypeEnum.OnShop,
                  selectedProductType: _productTypeEnum,
                  onChanged: (val) {
                    setState(() => _productTypeEnum = val);
                  },
                ),
                const SizedBox(height: 8),
                MyRadioButton(
                  title: ProductTypeEnum.Reserver.name,
                  value: ProductTypeEnum.Reserver,
                  selectedProductType: _productTypeEnum,
                  onChanged: (val) {
                    setState(() => _productTypeEnum = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text("Go to Shopping"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Shopping(
                      productName: _productController.text,
                      productDes: _productDesController.text,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
