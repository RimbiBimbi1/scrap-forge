import 'package:flutter/material.dart';

const double magnifierRadius = 50;

class FramingTool extends StatefulWidget {
  final imageKey;
  final List<Offset> points;
  final ValueSetter<List<Offset>> setCorners;

  const FramingTool(
      {super.key,
      required this.imageKey,
      required this.points,
      required this.setCorners});

  @override
  State<FramingTool> createState() => _FramingToolState();
}

class _FramingToolState extends State<FramingTool> {
  Offset magnifierPosition = Offset.zero;
  int movingCorner = -1;

  Size _getSize() {
    final size = widget.imageKey.currentContext!.size;
    if (size != null) {
      return size;
    }
    return const Size(0, 0);
  }

  void getClosestCorner(DragStartDetails details) {
    int i = 0;
    double minDistance = double.infinity;
    double distance = double.infinity;

    double x = details.localPosition.dx;
    double y = details.localPosition.dy;
    // Offset position = Offset(x, y);

    for (final (index, p) in widget.points.indexed) {
      distance = (x - p.dx) * (x - p.dx) + (y - p.dy) * (y - p.dy);
      if (distance < minDistance) {
        minDistance = distance;
        i = index;
      }
    }

    setState(() {
      movingCorner = i;
    });
  }

  void calcMagnifierPosition(DragUpdateDetails details) {
    Offset current = widget.points[movingCorner];

    Offset newPosition = current + details.delta;

    Size widgetSize = _getSize();

    double maxXOffset = widgetSize.width;
    double maxYOffset = widgetSize.height;

    if (newPosition.dx < 0) {
      newPosition = Offset(0, newPosition.dy);
    }
    if (newPosition.dy < 0) {
      newPosition = Offset(newPosition.dx, 0);
    }
    if (newPosition.dx > maxXOffset) {
      newPosition = Offset(maxXOffset, newPosition.dy);
    }
    if (newPosition.dy > maxYOffset) {
      newPosition = Offset(newPosition.dx, maxYOffset);
    }

    setState(() {
      widget.points[movingCorner] = newPosition;
    });
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
          onPanStart: getClosestCorner,
          onPanUpdate: calcMagnifierPosition,
          onPanEnd: (DragEndDetails details) =>
              {widget.setCorners(widget.points)},
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
