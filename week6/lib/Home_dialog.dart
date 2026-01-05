import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*final random = Random();
    int num_random = random.nextInt(100);
    */
    return Scaffold(
      appBar: AppBar(title: Text("OomyWeek6")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Go to shopping"),
                        Icon(Icons.add_shopping_cart_outlined),
                      ],
                    ),
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("AlertDialog Title"),
                        content: const Text("AlertDialog description"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, "Cancel"),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, "OK"),
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      fixedSize: Size(300, 80),
                      textStyle: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Color.fromRGBO(255, 102, 188, 1),
                      foregroundColor: Color.fromRGBO(0, 119, 221, 1),
                      elevation: 20,
                      shadowColor: Color.fromRGBO(255, 102, 188, 1),
                      side: BorderSide(color: Colors.black87, width: 2),
                      shape: StadiumBorder(),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text("OUTLINED BUTTON"),
                    style: OutlinedButton.styleFrom(fixedSize: Size(300, 80)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("TEXTBUTTON"),
                    style: OutlinedButton.styleFrom(fixedSize: Size(300, 80)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
