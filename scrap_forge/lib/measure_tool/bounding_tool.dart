import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const double magnifierRadius = 50;

class BoundingTool extends StatefulWidget {
  final imageKey;
  final List<Offset> points;
  final ValueSetter<List<Offset>> setCorners;

  const BoundingTool(
      {super.key,
      required this.imageKey,
      required this.points,
      required this.setCorners});

  @override
  State<BoundingTool> createState() => _FramingToolState();
}

class _FramingToolState extends State<BoundingTool> {
  Offset magnifierPosition = Offset.zero;
  int activeArea = -1;
  bool trivialMode = false;

  final Color defaultColor = Colors.white;
  final focusColor = Colors.amber;

  List<List<double>> linearCoefficients = List.empty();

  Size _getSize() {
    final size = widget.imageKey.currentContext!.size;
    if (size != null) {
      return size;
    }
    return const Size(0, 0);
  }

  void getActiveArea(DragStartDetails details) {
    int index = -1;

    double x = details.localPosition.dx;
    double y = details.localPosition.dy;

    List<Offset> points = widget.points;

    List<List<double>> temp = List.from([
      [0.0, 0.0],
      [0.0, 0.0],
      [0.0, 0.0],
      [0.0, 0.0],
    ]);

    if (!trivialMode) {
      //two points for two perpendicular axis directions
      for (final i in [0, 1]) {
        double a = (points[i + 1].dy - points[i].dy) /
            (points[i + 1].dx - points[i].dx);

        //two points for two offsets (0 degree monomials) of linear functions
        for (final j in [0, 2]) {
          int k = i + j;
          double b = points[k].dy - points[k].dx * a;

          temp[k][0] = a;
          temp[k][1] = b;
        }
      }
    }

    double minAxisDistance = double.infinity;

    for (final (i, l) in temp.indexed) {
      int j = (i + 1) % 4;

      double axisDistance;

      if (!trivialMode) {
        axisDistance = (l[0] * x - y + l[1]).abs() / math.sqrt(l[0] * l[0] + 1);
      } else {
        if (points[j].dx == points[i].dx) {
          axisDistance = (x - points[i].dx).abs();
        } else {
          axisDistance = (y - points[i].dy).abs();
        }
      }

      double p1Distance2 = (x - points[i].dx) * (x - points[i].dx) +
          (y - points[i].dy) * (y - points[i].dy);
      double p2Distance2 = (x - points[j].dx) * (x - points[j].dx) +
          (y - points[j].dy) * (y - points[j].dy);

      double borderLength2 =
          (points[j].dx - points[i].dx) * (points[j].dx - points[i].dx) +
              (points[j].dy - points[i].dy) * (points[j].dy - points[i].dy);

      if ((p1Distance2 < borderLength2) &&
          (p2Distance2 < borderLength2) &&
          (axisDistance < magnifierRadius) &&
          (axisDistance < minAxisDistance)) {
        minAxisDistance = axisDistance;
        index = i;
      }
    }

    if (index == -1) {
      index = 4;
    }

    setState(() {
      activeArea = index;
      linearCoefficients = temp;
    });
  }

  void calcMagnifierPositions(DragUpdateDetails details) {
    if (0 <= activeArea && activeArea < 4) {
      Offset finger = details.delta;

      List<int> perpendicularEdges =
          List.from([(activeArea - 1) % 4, (activeArea + 1) % 4]);

      List<Offset> newPositions = List.empty(growable: true);

      if (!trivialMode) {
        double bUpdated = finger.dy -
            finger.dx * linearCoefficients[activeArea][0] +
            linearCoefficients[activeArea][1];

        for (final i in perpendicularEdges) {
          double x = (linearCoefficients[i][1] - bUpdated) /
              (linearCoefficients[activeArea][0] - linearCoefficients[i][0]);
          double y = linearCoefficients[activeArea][0] * x + bUpdated;

          newPositions.add(Offset(x, y));
        }
        setState(() {
          linearCoefficients[activeArea][1] = bUpdated;

          widget.points[activeArea] = newPositions[0];
          widget.points[(activeArea + 1) % 4] = newPositions[1];
        });
      } else {
        int i = activeArea;
        int j = (activeArea + 1) % 4;
        Offset corner1 = widget.points[i];
        Offset corner2 = widget.points[j];
        if (corner1.dx == corner2.dx) {
          newPositions.add(Offset(corner1.dx + finger.dx, corner1.dy));
          newPositions.add(Offset(corner2.dx + finger.dx, corner2.dy));
        } else {
          newPositions.add(Offset(corner1.dx, corner1.dy + finger.dy));
          newPositions.add(Offset(corner2.dx, corner2.dy + finger.dy));
        }
        setState(() {
          widget.points[activeArea] = newPositions[0];
          widget.points[(activeArea + 1) % 4] = newPositions[1];
        });
      }
    } else {
      setState(() {
        List<Offset> newCorners =
            widget.points.map((e) => e + details.delta).toList();

        widget.points[0] = newCorners[0];
        widget.points[1] = newCorners[1];
        widget.points[2] = newCorners[2];
        widget.points[3] = newCorners[3];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if ((widget.points[1].dx - widget.points[0].dx == 0) ||
        (widget.points[1].dy - widget.points[0].dy == 0)) {
      setState(() {
        trivialMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // widget.setCorners(points);
    return Stack(
      children: [
        GestureDetector(
          onPanStart: getActiveArea,
          onPanUpdate: calcMagnifierPositions,
          onPanEnd: (DragEndDetails details) => {
            widget.setCorners(widget.points),
            setState(() {
              activeArea = -1;
            })
          },
        ),
        // ...widget.points.map((e) => Positioned(
        //     left: e.dx - magnifierRadius,
        //     top: e.dy - magnifierRadius,
        //     child: const RawMagnifier(
        //       decoration: MagnifierDecoration(
        //         shape: CircleBorder(
        //           side: BorderSide(color: Colors.white, width: 2),
        //         ),
        //       ),
        //       size: Size(magnifierRadius * 2, magnifierRadius * 2),
        //       magnificationScale: 2,
        //     ))),
        CustomPaint(
          painter: FramePainter(
              points: widget.points,
              activeArea: activeArea,
              defaultColor: defaultColor,
              focusColor: focusColor),
        )
      ],
    );
  }
}

class FramePainter extends CustomPainter {
  final List<Offset> points;
  final activeArea;
  final defaultColor;
  final focusColor;

  FramePainter(
      {required this.points,
      required this.activeArea,
      required this.defaultColor,
      required this.focusColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;

      final color =
          (activeArea == 4 || i == activeArea) ? focusColor : defaultColor;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2;

      canvas.drawLine(points[i], points[j], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
