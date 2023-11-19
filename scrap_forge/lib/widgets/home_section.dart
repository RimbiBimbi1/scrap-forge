import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  Color? background;

  Widget? header;
  List<Widget> children;

  HomeSection(
      {super.key, this.background, this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      color: background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: header,
          ),
          Row(
            children: children,
          ),
        ],
      ),
    );
  }
}
