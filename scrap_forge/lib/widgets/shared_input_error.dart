import 'package:flutter/material.dart';

class SharedErrorField extends StatelessWidget {
  final String? Function(String?) validator;
  const SharedErrorField({super.key, required this.validator});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 25,
        child: TextFormField(
          readOnly: true,
          validator: validator,
        ),
      ),
    );
  }
}
