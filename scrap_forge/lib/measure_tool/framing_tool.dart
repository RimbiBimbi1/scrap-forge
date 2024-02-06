import 'package:flutter/material.dart';

const double magnifierRadius = 35;

class FramingTool extends StatefulWidget {
  final Size size;
  final List<Offset> points;
  final Widget Function(double w, double h) displayImage;

  final ValueSetter<List<Offset>> setCorners;

  const FramingTool({
    super.key,
    required this.size,
    required this.displayImage,
    required this.points,
    required this.setCorners,
  });

  @override
  State<FramingTool> createState() => _FramingToolState();
}

class _FramingToolState extends State<FramingTool> {
  Offset magnifierPosition = Offset.zero;
  int activeCorner = -1;

  Widget image = Container();

  @override
  void initState() {
    super.initState();

    image = widget.displayImage(widget.size.width, widget.size.height);
  }

  void getClosestCorner(DragStartDetails details) {
    int i = 0;
    double minDistance2 = double.infinity;
    double distance2 = double.infinity;

    double x = details.localPosition.dx;
    double y = details.localPosition.dy;

    for (final (index, p) in widget.points.indexed) {
      distance2 = (x - p.dx) * (x - p.dx) + (y - p.dy) * (y - p.dy);
      if (distance2 < minDistance2) {
        minDistance2 = distance2;
        i = index;
      }
    }

    setState(() {
      activeCorner = i;
    });
  }

  void calcMagnifierPosition(DragUpdateDetails details) {
    Offset current = widget.points[activeCorner];

    Offset newPosition = current + details.delta;

    double maxXOffset = widget.size.width;
    double maxYOffset = widget.size.height;

    if (newPosition.dx < 0) {
      newPosition = Offset(0, newPosition.dy);
    } else if (newPosition.dx > maxXOffset) {
      newPosition = Offset(maxXOffset, newPosition.dy);
    }
    if (newPosition.dy < 0) {
      newPosition = Offset(newPosition.dx, 0);
    } else if (newPosition.dy > maxYOffset) {
      newPosition = Offset(newPosition.dx, maxYOffset);
    }

    setState(() {
      widget.points[activeCorner] = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Color defaultColor = Color.fromARGB(255, 255, 0, 0);
    Color focusColor = Color.fromARGB(255, 255, 255, 255);
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
                  onPanStart: getClosestCorner,
                  onPanUpdate: calcMagnifierPosition,
                  onPanEnd: (DragEndDetails details) => {
                    setState(() {
                      activeCorner = -1;
                    })
                  },
                ),
                ...widget.points
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
                                    color: activeCorner == index
                                        ? focusColor
                                        : defaultColor,
                                    width: 2),
                              ),
                            ),
                            size: const Size(
                                magnifierRadius * 2, magnifierRadius * 2),
                            magnificationScale: 2,
                          ),
                        ),
                      ),
                    )
                    .values,
                CustomPaint(
                  painter: FramePainter(
                      points: widget.points,
                      activeCorner: activeCorner,
                      defaultColor: defaultColor,
                      focusColor: focusColor),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: theme.colorScheme.secondary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => widget.setCorners(widget.points),
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
  final int activeCorner;
  final Color defaultColor;
  final Color focusColor;

  FramePainter(
      {required this.points,
      required this.activeCorner,
      required this.defaultColor,
      required this.focusColor});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;

      final paint = Paint()
        ..color = defaultColor
        ..strokeWidth = 2;

      canvas.drawLine(points[i], points[j], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
