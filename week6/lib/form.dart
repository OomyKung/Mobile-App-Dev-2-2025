import 'package:flutter/material.dart';
import 'shopping.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();

  String productName = '';
  String customerName = '';
  int price = 0;
  int amount = 0;

  int get totalPrice => price * amount;

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form"),
        backgroundColor: const Color.fromRGBO(255, 102, 188, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildTextField(
              controller: _productController,
              label: "Product Name",
              onChanged: (val) => setState(() => productName = val),
            ),
            _buildTextField(
              controller: _priceController,
              label: "Product Price",
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => price = int.tryParse(val) ?? 0),
            ),
            _buildTextField(
              controller: _amountController,
              label: "Number of Product",
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => amount = int.tryParse(val) ?? 0),
            ),
            _buildTextField(
              controller: _customerController,
              label: "Customer Name",
              onChanged: (val) => setState(() => customerName = val),
            ),

            const SizedBox(height: 20),
            Text(
              "Product Name : $productName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            Text(
              "Price : $price",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            Text(
              "Amount : $amount",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            /// 🔥 RESULT
            Text(
              "Total Price : $totalPrice",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 20),
            _buildButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.check_circle_outline),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed:
            productName.isEmpty ||
                customerName.isEmpty ||
                price <= 0 ||
                amount <= 0
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormShopping(
                      productName: productName,
                      customerName: customerName,
                      price: price,
                      amount: amount,
                      totalPrice: totalPrice,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Go to Shopping",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            Icon(Icons.shopping_cart),
          ],
        ),
      ),
    );
  }
}
