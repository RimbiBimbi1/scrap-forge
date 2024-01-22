import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final Widget? label;
  final TextInputType type;
  final int? maxLines;
  final String? initialValue;
  final String? Function(String? value) validator;
  final TextEditingController controller;
  final void Function()? onEditingComplete;
  final void Function(String? value)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.onEditingComplete,
    this.onChanged,
    this.initialValue,
    this.type = TextInputType.text,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        initialValue: initialValue,
        inputFormatters: inputFormatters,
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          errorMaxLines: 5,
          label: label,
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: theme.colorScheme.outline, width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        ),
      ),
    );
  }
}
