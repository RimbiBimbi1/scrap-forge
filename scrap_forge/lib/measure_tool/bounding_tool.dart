import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/db_entities/product.dart';

double initialMagnifierRadius = 30;

class BoundingTool extends StatefulWidget {
  final Size size;

  final List<Offset> points;
  final Widget Function(double w, double h) displayImage;
  final SheetFormat sheetFormat;
  final int projectionAreaPixels;
  final Function(List<double>)? onBoundingBoxConfirmed;

  const BoundingTool({
    super.key,
    required this.displayImage,
    required this.points,
    required this.size,
    required this.projectionAreaPixels,
    required this.sheetFormat,
    this.onBoundingBoxConfirmed,
  });

  @override
  State<BoundingTool> createState() => _FramingToolState();
}

class _FramingToolState extends State<BoundingTool> {
  List<Offset> corners = List.empty();
  Offset magnifierPosition = Offset.zero;
  int activeArea = -1;
  /*
    -1: nothing,
    0-3: walls, stretching
    4-7: corners, rotating
    8: whole frame, moving
  */
  bool trivialMode = false;
  double magnifierRadius = initialMagnifierRadius;

  List<List<double>> linearCoefficients = List.empty();
  double projectionAreaCM2 = 0;

  Widget image = Container();

  @override
  void initState() {
    super.initState();

    corners = widget.points;
    double newRadius = calcMagnifierRadius(widget.points);

    if (magnifierRadius != newRadius) {
      magnifierRadius = newRadius;
    }
    trivialMode = checkTrivialMode(widget.points);
    image = widget.displayImage(widget.size.width, widget.size.height);
  }

  double calcMagnifierRadius(List<Offset> magnifiers) {
    return math.max(
      math.min(
          math.min(
                (magnifiers[0] - magnifiers[3]).distance,
                (magnifiers[0] - magnifiers[1]).distance,
              ) /
              2,
          initialMagnifierRadius),
      10,
    );
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

    List<Offset> points = corners;

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

      double newRadius = calcMagnifierRadius([
        newPositions[0],
        newPositions[1],
        corners[(activeArea + 2) % 4],
        corners[(activeArea + 3) % 4]
      ]);

      List<Offset> updated = List.from(corners);
      updated[activeArea] = newPositions[0];
      updated[(activeArea + 1) % 4] = newPositions[1];

      setState(
        () {
          if (magnifierRadius != newRadius) {
            magnifierRadius = newRadius;
          }

          linearCoefficients[activeArea][1] = bUpdated;
          corners = updated;
        },
      );
    } else {
      int i = activeArea;
      int j = (activeArea + 1) % 4;
      Offset corner1 = corners[i];
      Offset corner2 = corners[j];
      if (corner1.dx == corner2.dx) {
        newPositions.add(Offset(corner1.dx + finger.dx, corner1.dy));
        newPositions.add(Offset(corner2.dx + finger.dx, corner2.dy));
      } else {
        newPositions.add(Offset(corner1.dx, corner1.dy + finger.dy));
        newPositions.add(Offset(corner2.dx, corner2.dy + finger.dy));
      }
      double newRadius = calcMagnifierRadius([
        newPositions[0],
        newPositions[1],
        corners[(activeArea + 2) % 4],
        corners[(activeArea + 3) % 4]
      ]);

      List<Offset> updated = List.from(corners);
      updated[activeArea] = newPositions[0];
      updated[(activeArea + 1) % 4] = newPositions[1];

      setState(() {
        if (magnifierRadius != newRadius) {
          magnifierRadius = newRadius;
        }

        corners = updated;
      });
    }
  }

  void rotate(DragUpdateDetails details) {
    List<Offset> points = corners;
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

    List<Offset> updated = List.from(corners);
    updated[i] = rotated[0];
    updated[(i + 1) % 4] = rotated[1];
    updated[(i + 2) % 4] = rotated[2];
    updated[(i + 3) % 4] = rotated[3];

    setState(() {
      trivialMode = checkTrivialMode(rotated);
      corners = updated;
    });
  }

  void move(DragUpdateDetails details) {
    setState(() {
      corners = corners.map((e) => e + details.delta).toList();
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
    double ratio = max(widget.sheetFormat.height, widget.sheetFormat.width) /
        widget.size.height;
    double dim1 = (corners[0] - corners[1]).distance * ratio;
    double dim2 = (corners[1] - corners[2]).distance * ratio;
    double area =
        math.min(widget.projectionAreaPixels * ratio * ratio, dim1 * dim2);

    return List.from([dim1, dim2, area]);
  }

  Future<void> _displayDecisionDialog(List<double> dimensions) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/measure'),
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Wróć do strony głównej"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Product product = Product()
                          ..name = ''
                          ..dimensions = Dimensions(
                            length: dimensions[0],
                            width: dimensions[1],
                            projectionArea: dimensions[2],
                            lengthDisplayUnit: SizeUnit.centimeter,
                            widthDisplayUnit: SizeUnit.centimeter,
                            // heightDisplayUnit: SizeUnit.millimeter,
                            areaDisplayUnit: SizeUnit.centimeter,
                          );

                        Navigator.popUntil(
                          context,
                          ModalRoute.withName('/measure'),
                        );
                        Navigator.pushReplacementNamed(
                          context,
                          '/editProduct',
                          arguments: {"productData": product},
                        );
                      },
                      child: Text("Dodaj do nowego produktu"))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Color defaultColor = const Color.fromARGB(255, 255, 255, 255);
    Color focusColor = Color.fromARGB(255, 255, 200, 0);

    List<double> dimensions = calculateDimensions();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox.shrink(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: SizedBox(
            width: widget.size.width,
            height: widget.size.height,
            child: Stack(
              children: [
                image,
                GestureDetector(
                  onPanStart: getActiveArea,
                  onPanUpdate: calcMagnifierPositions,
                  onPanEnd: (DragEndDetails details) => {
                    setState(() {
                      activeArea = -1;
                    })
                  },
                ),
                ...corners
                    .asMap()
                    .map(
                      (index, mag) => MapEntry(
                        index,
                        Positioned(
                          left: mag.dx - magnifierRadius,
                          top: mag.dy - magnifierRadius,
                          child: RawMagnifier(
                            decoration: MagnifierDecoration(
                              shape: CircleBorder(
                                side: BorderSide(
                                    color: activeArea == index + 4
                                        ? focusColor
                                        : defaultColor,
                                    width: 2),
                              ),
                            ),
                            size:
                                Size(magnifierRadius * 2, magnifierRadius * 2),
                            magnificationScale: 1,
                          ),
                        ),
                      ),
                    )
                    .values,
                CustomPaint(
                  painter: FramePainter(
                      points: corners,
                      activeArea: activeArea,
                      defaultColor: defaultColor,
                      focusColor: focusColor),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: theme.colorScheme.secondary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Długość: ${math.max(dimensions[0], dimensions[1]).round()}mm",
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                  Text(
                    "Szerokość: ${math.min(dimensions[0], dimensions[1]).round()}mm",
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                  Text(
                    "Pole przedmiotu: ${(dimensions[2] * 0.01).toStringAsFixed(2)}cm2",
                    style: TextStyle(color: theme.colorScheme.onSecondary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.onBoundingBoxConfirmed != null) {
                    widget.onBoundingBoxConfirmed!(
                      List<double>.from(
                        [
                          dimensions[0],
                          dimensions[1],
                          dimensions[2],
                        ],
                      ),
                    );
                    Navigator.popUntil(
                        context, ModalRoute.withName('/measure'));
                    Navigator.pop(context);
                  } else {
                    _displayDecisionDialog(dimensions);
                  }
                },
                child: const Text("Zatwierdź"),
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
  final int activeArea;
  final Color defaultColor;
  final Color focusColor;

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
