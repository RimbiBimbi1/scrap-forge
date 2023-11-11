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

    //two points for two perpendicular axis directions
    for (final i in [0, 1]) {
      double a =
          (points[i + 1].dy - points[i].dy) / (points[i + 1].dx - points[i].dx);

      //two points for two offsets (0 degree monomials) of linear functions
      for (final j in [0, 2]) {
        //j*2 for getting the parallel line index
        int k = i + j;
        double b = points[k].dy - points[k].dx * a;

        temp[k][0] = a;
        temp[k][1] = b;
      }
    }

    double minDistance = double.infinity;
    double distance = double.infinity;

    for (final (i, l) in temp.indexed) {
      distance = (l[0] * x - y + l[1]).abs() / math.sqrt(l[0] * l[0] + 1);
      if ((distance < 50) && (distance < minDistance)) {
        minDistance = distance;
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
      Offset current1 = widget.points[activeArea];
      Offset current2 = widget.points[(activeArea + 1) % 4];

      Offset finger = details.delta;

      double bUpdated = finger.dy -
          finger.dx * linearCoefficients[activeArea][0] +
          linearCoefficients[activeArea][1];

      List<int> perpendicularEdges =
          List.from([(activeArea - 1) % 4, (activeArea + 1) % 4]);

      List<Offset> newPositions = List.empty(growable: true);

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

  // @override
  // void initState() {
  //   super.initState();
  //   setState(() {
  //     widget.points = widget.points;
  //   });
  // }

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
        ...widget.points.map((e) => Positioned(
            left: e.dx - magnifierRadius,
            top: e.dy - magnifierRadius,
            child: const RawMagnifier(
              decoration: MagnifierDecoration(
                shape: CircleBorder(
                  side: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              size: Size(magnifierRadius * 2, magnifierRadius * 2),
              magnificationScale: 2,
            ))),
        CustomPaint(
          painter: FramePainter(points: widget.points),
        )
      ],
    );
  }
}

class FramePainter extends CustomPainter {
  final List<Offset> points;

  FramePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    canvas.drawLine(points.last, points[0], paint);
    for (int i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
