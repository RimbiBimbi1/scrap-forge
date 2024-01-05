import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String label;
  TextInputType type;
  int? maxLines;
  String? initialValue;
  String? Function(String? value) validator;
  TextEditingController controller;

  CustomTextField(
      {super.key,
      required this.label,
      required this.controller,
      required this.validator,
      this.initialValue,
      this.type = TextInputType.text,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        initialValue: initialValue,
        // onSaved: onSaved,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            label: Text(
              label,
              style: const TextStyle(color: Colors.white),
              textScaleFactor: 1.05,
            ),
            // disabledBorder: OutlineInputBorder(
            //     borderSide: BorderSide(color: Colors.grey[800]!)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[800]!)),
            contentPadding: const EdgeInsets.all(15)),
      ),
    );
  }
}
