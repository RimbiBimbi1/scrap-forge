import 'package:flutter/material.dart';
import 'dart:math' as math;

const double magnifierRadius = 25;

class BoundingTool extends StatefulWidget {
  final List<Offset> points;
  final Widget image;
  final double mmHeight;
  final Size size;
  final int projectionAreaPixels;
  final ValueSetter<List<Offset>> setCorners;

  const BoundingTool(
      {super.key,
      required this.image,
      required this.points,
      required this.size,
      required this.projectionAreaPixels,
      required this.mmHeight,
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
  double projectionAreaCM2 = 0;

  @override
  void initState() {
    super.initState();

    double ratio = widget.mmHeight / widget.size.height;
    setState(() {
      projectionAreaCM2 = widget.projectionAreaPixels * ratio * ratio * 0.01;
      trivialMode = checkTrivialMode(widget.points);
    });
  }

  bool checkTrivialMode(List<Offset> points) {
    if ((points[1].dx - points[0].dx == 0) ||
        (points[1].dy - points[0].dy == 0)) {
      return true;
    }
    return false;
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

    List<double> cornerDistances = List.empty(growable: true);

    for (final (i, p) in points.indexed) {
      double distance =
          math.sqrt((p.dx - x) * (p.dx - x) + (p.dy - y) * (p.dy - y));
      if (distance < magnifierRadius) {
        setState(() {
          activeArea = 4 + i;
        });
        return;
      }
      cornerDistances.add(distance);
    }

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

      double borderLength = math.sqrt(
          (points[j].dx - points[i].dx) * (points[j].dx - points[i].dx) +
              (points[j].dy - points[i].dy) * (points[j].dy - points[i].dy));

      if ((cornerDistances[i] < borderLength) &&
          (cornerDistances[j] < borderLength) &&
          (axisDistance < magnifierRadius) &&
          (axisDistance < minAxisDistance)) {
        minAxisDistance = axisDistance;
        index = i;
      }
    }

    if (index == -1) index = 8;

    setState(() {
      activeArea = index;
      linearCoefficients = temp;
    });
  }

  void stretch(DragUpdateDetails details) {
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
      setState(
        () {
          linearCoefficients[activeArea][1] = bUpdated;

          widget.points[activeArea] = newPositions[0];
          widget.points[(activeArea + 1) % 4] = newPositions[1];
        },
      );
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
  }

  void rotate(DragUpdateDetails details) {
    List<Offset> points = widget.points;
    int i = activeArea % 4;
    // Offset linePrecursor = widget.points[i] + details.delta;
    Offset rectangleCenter = Offset(
      (points[i].dx + points[(i + 2) % 4].dx) / 2,
      (points[i].dy + points[(i + 2) % 4].dy) / 2,
    );

    Offset centerToCornerVector = points[i] - rectangleCenter;
    Offset centerToNeighborVector = points[(i + 1) % 4] - rectangleCenter;
    double rotationAngle = (details.localPosition - rectangleCenter).direction -
        (centerToCornerVector).direction;

    double sin = math.sin(rotationAngle);
    double cos = math.cos(rotationAngle);

    Offset cTCVRotated = Offset(
        centerToCornerVector.dx * cos - centerToCornerVector.dy * sin,
        centerToCornerVector.dx * sin + centerToCornerVector.dy * cos);
    Offset cTNVRotated = Offset(
        centerToNeighborVector.dx * cos - centerToNeighborVector.dy * sin,
        centerToNeighborVector.dx * sin + centerToNeighborVector.dy * cos);

    List<Offset> rotated = List.from([
      rectangleCenter + cTCVRotated,
      rectangleCenter + cTNVRotated,
      rectangleCenter - cTCVRotated,
      rectangleCenter - cTNVRotated
    ]);

    setState(() {
      trivialMode = checkTrivialMode(rotated);
      widget.points[i] = rotated[0];
      widget.points[(i + 1) % 4] = rotated[1];
      widget.points[(i + 2) % 4] = rotated[2];
      widget.points[(i + 3) % 4] = rotated[3];
    });
  }

  void move(DragUpdateDetails details) {
    setState(() {
      widget.points[0] += details.delta;
      widget.points[1] += details.delta;
      widget.points[2] += details.delta;
      widget.points[3] += details.delta;
    });
  }

  void calcMagnifierPositions(DragUpdateDetails details) {
    switch (activeArea) {
      case 0:
      case 1:
      case 2:
      case 3:
        stretch(details);
        break;
      case 4:
      case 5:
      case 6:
      case 7:
        rotate(details);
        break;
      case 8:
        move(details);
    }
  }

  List<double> calculateDimensions() {
    double ratio = widget.mmHeight / widget.size.height;
    double dim1 = (widget.points[0] - widget.points[1]).distance * ratio;
    double dim2 = (widget.points[1] - widget.points[2]).distance * ratio;

    return List.from([dim1, dim2]);
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    List<double> dimensions = calculateDimensions();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size.width,
          height: widget.size.height,
          child: Stack(
            children: [
              widget.image,
              GestureDetector(
                onPanStart: getActiveArea,
                onPanUpdate: calcMagnifierPositions,
                onPanEnd: (DragEndDetails details) => {
                  // widget.setCorners(widget.points),
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
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    size: Size(magnifierRadius * 2, magnifierRadius * 2),
                    magnificationScale: 1,
                  ))),
              CustomPaint(
                painter: FramePainter(
                    points: widget.points,
                    activeArea: activeArea,
                    defaultColor: defaultColor,
                    focusColor: focusColor),
              ),
            ],
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Długość: ${dimensions[0].round()}mm",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Szerokość: ${dimensions[1].round()}mm",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Pole przedmiotu: ${projectionAreaCM2.round()}cm2",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => {
                  arguments['onExit'](
                    List<double>.from(
                      [dimensions[0], dimensions[1], projectionAreaCM2],
                    ),
                  ),
                  Navigator.pop(context),
                },
                child: Text("Zatwierdź"),
              ),
            ],
          ),
        ),
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
          (activeArea == 8 || i == activeArea) ? focusColor : defaultColor;
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
