import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomGridTile extends StatelessWidget {
  Color? background;
  Widget? child;
  String title;
  final onPressed;

  CustomGridTile({
    super.key,
    this.onPressed,
    this.child,
    this.title = "",
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: Center(
        child: Text(
          title,
          textScaleFactor: 1.5,
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: TextButton(
            onPressed: onPressed,
            style: ButtonStyle(
                padding: MaterialStateProperty.resolveWith(
                    (states) => EdgeInsets.all(0))),
            child: Container(
              padding: EdgeInsets.all(30),
              child: SizedBox.expand(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
