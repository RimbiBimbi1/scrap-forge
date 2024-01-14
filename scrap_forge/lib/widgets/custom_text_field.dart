import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextInputType type;
  final int? maxLines;
  final String? initialValue;
  final String? Function(String? value) validator;
  final TextEditingController controller;

  const CustomTextField(
      {super.key,
      required this.label,
      required this.controller,
      required this.validator,
      this.initialValue,
      this.type = TextInputType.text,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        initialValue: initialValue,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
            label: Text(
              label,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.outline, width: 1)),
            contentPadding: const EdgeInsets.all(18)),
      ),
    );
  }
}
