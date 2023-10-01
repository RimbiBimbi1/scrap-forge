import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImageTools;
import 'dart:math' as math;

import 'package:scrap_forge/measure_tool/ImageProcessor.dart';

class MeasureTool extends StatefulWidget {
  const MeasureTool({super.key});

  @override
  State<MeasureTool> createState() => _MeasureToolState();
}

class _MeasureToolState extends State<MeasureTool> {
  List<ImageTools.Image> imageHistory =
      List.of([ImageTools.Image(width: 0, height: 0)]);

  List<List<double>> xSobel = List.empty();
  List<List<double>> ySobel = List.empty();

  Future<void> loadImage(path) async {
    ByteData data = await rootBundle.load(path);
    ImageTools.Image? image = ImageTools.decodeJpg(data.buffer.asUint8List());
    if (image != null) {
      num aaaa = image.getPixel(100, 100).g;
      setState(() {
        imageHistory.add(image);
      });
    }
  }

  MemoryImage displayImage(ImageTools.Image image) {
    List<int>? withHeader = ImageTools.encodeJpg(image);
    return MemoryImage(Uint8List.fromList(withHeader));
  }

  void addToHistory(ImageTools.Image img) {
    setState(() {
      if (imageHistory.length > 5) {
        imageHistory.removeAt(0);
      }
      imageHistory.add(img);
    });
  }

  void extendImage() {
    ImageTools.Image ext =
        ImageProcessor(imageHistory.last).getExtendedImage(1);
    setState(() {
      addToHistory(ext);
    });
  }

  void toGreyscale() {
    ImageTools.Image gs = ImageProcessor(imageHistory.last).getGrayscale();
    setState(() {
      addToHistory(gs);
    });
  }

  void applyGaussian() {
    ImageTools.Image gb = ImageProcessor(imageHistory.last)
        .getGaussianBlurred(kernelRadius: 1, sd: 1.4);
    setState(() {
      addToHistory(gb);
    });
  }

  void calculateDirectionalSobel() {
    List<List<int>> Kx = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    List<List<int>> Ky = [
      [1, 2, 1],
      [0, 0, 0],
      [-1, -2, -1]
    ];

    setState(() {
      xSobel = ImageProcessor(imageHistory.last).getDirectionalSobel(Kx);
      ySobel = ImageProcessor(imageHistory.last).getDirectionalSobel(Ky);
    });
  }

  void applySobel() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getSobel(xSobel, ySobel));
    });
  }

  void applyNonMaxSuppression() {
    ImageProcessor iP = ImageProcessor(imageHistory.last);
    List<List<double>> direction = iP.getSobelDirection(xSobel, ySobel);

    setState(() {
      addToHistory(iP.getNonMaxSuppression(direction));
    });
  }

  void applyDoubleThreshold() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getDoubleThresholded());
    });
  }

  void applyHysteresis() {
    setState(() {
      // imageHistory =
      //     List.of([ImageProcessor(imageHistory.last).getHysteresised()]);
      addToHistory(
          ImageProcessor(imageHistory.last).getHysteresised(kernelRadius: 1));
    });
  }

  void dilate() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getDilated());
    });
  }

  void erode() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getEroded());
    });
  }

  void floodfill() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getFloodfilled());
    });
  }

  void clearHistory() {
    setState(() {
      imageHistory = List.from([imageHistory.last]);
    });
  }

  void undo() {
    setState(() {
      if (imageHistory.length > 1) {
        imageHistory.removeLast();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadImage('assets/41.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pomiar"),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 1,
                child: Image(
                  image: displayImage(imageHistory.last),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: toGreyscale,
                  child: Text("Greyscale"),
                ),
                FloatingActionButton(
                    onPressed: extendImage, child: Text("Extend")),
                FloatingActionButton(
                  onPressed: applyGaussian,
                  child: Text("Blur"),
                ),
                FloatingActionButton(
                  onPressed: calculateDirectionalSobel,
                  child: Text("preSobel"),
                ),
                FloatingActionButton(
                  onPressed: applySobel,
                  child: Text("Sobel"),
                ),
                FloatingActionButton(
                  onPressed: applyNonMaxSuppression,
                  child: Text("Suppress"),
                ),
                FloatingActionButton(
                  onPressed: applyDoubleThreshold,
                  child: Text("Threshold"),
                ),
                FloatingActionButton(
                  onPressed: applyHysteresis,
                  child: Text("Hysteresis"),
                ),
                FloatingActionButton(
                  onPressed: erode,
                  child: Text("Erosion"),
                ),
                FloatingActionButton(
                  onPressed: dilate,
                  child: Text("Dilation"),
                ),
                FloatingActionButton(
                  onPressed: floodfill,
                  child: Text("Floodfill"),
                ),
                FloatingActionButton(
                  onPressed: undo,
                  child: Text("<-"),
                ),
                FloatingActionButton(
                  onPressed: clearHistory,
                  child: Text("Clear"),
                ),
              ].map((e) => Flexible(flex: 1, child: e)).toList(),
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey[700],
    );
  }
}
