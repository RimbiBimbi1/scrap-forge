import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final Color? background;
  final Color? color;
  final Widget? child;
  final String title;
  final onPressed;

  const CustomTile({
    super.key,
    this.onPressed,
    this.child,
    this.title = "",
    this.background,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 20,
      fit: FlexFit.tight,
      child: AspectRatio(
        aspectRatio: 0.75,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  alignment: Alignment.topLeft,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      alignment: AlignmentDirectional.topStart,
                      child: child,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Text(title,
                      textScaleFactor: 0.9,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: color,
                        letterSpacing: 01,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
