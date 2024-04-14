import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final Widget header;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      //Wygląd aplikacji
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          ...children.map((child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: child,
              )),
        ],
      ),
    );
  }
}
