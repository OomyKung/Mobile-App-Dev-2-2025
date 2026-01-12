import 'package:flutter/material.dart';
import 'inputForm.dart';

class MyRadioButton extends StatelessWidget {
  const MyRadioButton({
    Key? key,
    required this.title,
    required this.value,
    required this.selectedProductType,
    required this.onChanged,
  }) : super(key: key);

  final String title;
  final ProductTypeEnum value;
  final ProductTypeEnum? selectedProductType;
  final Function(ProductTypeEnum?) onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ProductTypeEnum>(
      title: Text(title),
      value: value,
      groupValue: selectedProductType,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
