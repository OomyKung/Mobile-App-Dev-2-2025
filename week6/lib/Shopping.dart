import 'package:flutter/material.dart';

class FormShopping extends StatelessWidget {
  final String productName;
  final String customerName;
  final int price;
  final int amount;
  final int totalPrice;

  const FormShopping({
    super.key,
    required this.productName,
    required this.customerName,
    required this.price,
    required this.amount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping"),
        backgroundColor: const Color.fromRGBO(255, 102, 188, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _itemTile("Product Name", productName),
          _itemTile("Customer Name", customerName),
          _itemTile("Price per item", price.toString()),
          _itemTile("Amount", amount.toString()),

          const Divider(thickness: 2),

          ListTile(
            title: const Text("Total Price", style: TextStyle(fontSize: 18)),
            trailing: Text(
              "$totalPrice",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
