import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTile extends StatelessWidget {
  Color? background;
  Widget? backgroundImage;
  Color? color;
  Widget? child;
  String title;
  final onPressed;

  CustomTile({
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
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 20),
                  alignment: Alignment.topLeft,
                  child: AspectRatio(
                    aspectRatio: 1,
                    // alignment: Alignment.topLeft,
                    child: Container(
                      child: child,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  // padding: EdgeInsets.all(5),
                  child: Text(title,
                      textScaleFactor: 1.1,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: color,
                        letterSpacing: 01,
                      )),
                ),
              ],
            ),
            // child: GridView.count(
            //   primary: false,
            //   crossAxisCount: 2,
            //   shrinkWrap: true,
            //   children: [
            //     Container(
            //       child: child,
            //     ),
            //     Container(),
            //     Container(),
            //     Container(
            //       alignment: Alignment.bottomRight,
            //       padding: EdgeInsets.all(5),
            //       child: Text(title),
            //     ),
            //   ],
          ),
        ),
      ),
    );
    // );
    //   child: SizedBox.expand(
    //     child: Container(
    //       decoration: BoxDecoration(
    //           color: background,
    //           borderRadius: BorderRadius.all(Radius.circular(10))),
    //       child: TextButton(
    //         onPressed: onPressed,
    //         style: ButtonStyle(
    //             padding: MaterialStateProperty.resolveWith(
    //                 (states) => EdgeInsets.all(0))),
    //         child: Container(
    //           padding: EdgeInsets.all(30),
    //           child: SizedBox.expand(child: child),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
