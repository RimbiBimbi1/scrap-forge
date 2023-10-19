import 'package:flutter/material.dart';

class BoundingTool extends StatefulWidget {
  final imageKey;

  const BoundingTool({
    super.key,
    required this.imageKey,
  });

  @override
  State<BoundingTool> createState() => _BoundingToolState();
}

class _BoundingToolState extends State<BoundingTool> {
  double calculateBBScore(double commonalityFactor, int width, int height) {
    return 0;
  }

  // void

  // void getOptimizedBoundingBox() {}

  @override
  Widget build(BuildContext context) {
    return Stack();
  }
}
