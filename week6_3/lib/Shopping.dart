import 'package:flutter/material.dart';

class Shopping extends StatelessWidget {
  const Shopping({
    Key? key,
    required this.productName,
    required this.productDes,
  }) : super(key: key);

  final String productName;
  final String productDes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Screen"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: Text(productName),
              subtitle: Text(productDes),
            ),
          ],
        ),
      ),
    );
  }
}
