import 'package:flutter/material.dart';

class A extends StatelessWidget {
  A({Key? key, required this.productName}) : super(key: key);
  String productName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Screen"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Color.fromRGBO(255, 102, 188, 1),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Go Back!"),
        ),
      ),
    );
  }
}
