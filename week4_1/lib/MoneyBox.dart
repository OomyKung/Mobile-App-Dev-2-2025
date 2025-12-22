import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoneyBox extends StatelessWidget {
  String title = "";
  double amount = 0;
  double sizeConHeight = 0;
  Color colorSet = Color.fromRGBO(255, 102, 188, 1);
  MoneyBox(this.title, this.amount, this.sizeConHeight, this.colorSet);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorSet,
        borderRadius: BorderRadius.circular(20),
      ),
      height: sizeConHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              '${NumberFormat("#,###.###").format(amount)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
