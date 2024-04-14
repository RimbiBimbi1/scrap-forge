import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final Widget? label;
  final TextInputType type;
  final int? maxLines;
  final String? initialValue;
  final String? Function(String? value) validator;
  final TextEditingController controller;
  final void Function(String? value)? onChanged;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.initialValue,
    this.type = TextInputType.text,
    this.maxLines = 1,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        validator: validator,
        initialValue: initialValue,
        inputFormatters: inputFormatters,
        onTap: onTap,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          errorMaxLines: 3,
          label: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        ),
      ),
    );
  }
}
