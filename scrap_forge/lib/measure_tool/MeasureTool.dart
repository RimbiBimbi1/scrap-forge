import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:path_provider/path_provider.dart';

import 'dart:math' as math;
import 'package:scrap_forge/measure_tool/CornerScanner.dart';
import 'package:scrap_forge/measure_tool/FramingTool.dart';
import 'package:scrap_forge/measure_tool/ImageProcessor.dart';
import 'package:scrap_forge/measure_tool/TriangleTexturer.dart';
import 'package:scrap_forge/measure_tool/AutoBoundingBoxScanner.dart';

class MeasureTool extends StatefulWidget {
  const MeasureTool({super.key});

  @override
  State<MeasureTool> createState() => _MeasureToolState();
}

class _MeasureToolState extends State<MeasureTool> {
  imgLib.Image photo = imgLib.Image(width: 0, height: 0);
  List<imgLib.Image> imageHistory =
      List.of([imgLib.Image(width: 0, height: 0)]);

  List<List<double>> xSobel = List.empty();
  List<List<double>> ySobel = List.empty();

  List<Offset> corners = List.empty();

  final _imageKey = GlobalKey();

  // Future _getStoragePermission() async {
  //   if (await Permission.storage.request().isGranted) {
  //     setState(() {
  //       permissionGranted = true;
  //     });
  //   }
  // }

  Future<void> loadImage(path) async {
    ByteData data = await rootBundle.load(path);
    imgLib.Image? image = imgLib.decodeJpg(data.buffer.asUint8List());
    if (image != null) {
      setState(() {
        photo = image;
        imageHistory.add(image);
      });
    }
  }

  Future<bool> saveImage() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    print(appDocDirectory.absolute);

    // final path = '${appDocDirectory.path}/saved.jpg';
    // return true;
    return await imgLib.encodeJpgFile(
        '${appDocDirectory.path}/saved.jpg', imageHistory.last);
  }

  MemoryImage displayImage(imgLib.Image image) {
    List<int>? withHeader = imgLib.encodeJpg(image);
    return MemoryImage(Uint8List.fromList(withHeader));
  }

  void addToHistory(imgLib.Image img) {
    setState(() {
      if (imageHistory.length > 5) {
        imageHistory.removeAt(0);
      }
      imageHistory.add(img);
    });
  }

  void extendImage() {
    imgLib.Image ext = ImageProcessor(imageHistory.last).getExtendedImage(1);
    setState(() {
      addToHistory(ext);
    });
  }

  void toGreyscale() {
    imgLib.Image gs = ImageProcessor(imageHistory.last).getGrayscale();
    setState(() {
      addToHistory(gs);
    });
  }

  void applyGaussian() {
    imgLib.Image gb = ImageProcessor(imageHistory.last)
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

  void findCorners() {
    CornerScanner cs = CornerScanner(imageHistory.last);
    List<imgLib.Point> scanned = cs.scanForCorners();
    double imgW = imageHistory.last.width.toDouble();
    double imgH = imageHistory.last.height.toDouble();
    Size displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    double displayW = displaySize.width;
    double displayH = displaySize.height;

    setState(() {
      corners = scanned
          .map((e) => Offset(e.x.toDouble() / imgW * displayW,
              e.y.toDouble() / imgH * displayH))
          .toList();
    });
  }

  void crop() {
    int a4Width = 840;
    int a4Height = 1188;

    double imgW = imageHistory.last.width.toDouble();
    double imgH = imageHistory.last.height.toDouble();
    Size displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    double displayW = displaySize.width;
    double displayH = displaySize.height;

    imgLib.Image a4 = imgLib.Image(width: a4Width, height: a4Height);

    List<imgLib.Point> URTriangleTexture = [0, 1, 2]
        .map((i) => imgLib.Point(
            corners[i].dx / displayW * imgW, corners[i].dy / displayH * imgH))
        .toList();
    // List<imgLib.Point> ULTriangle = List.from([imgLib.Point(corners[0].dx, corners[0].dy), imgLib.Point(corners[1].dx, corners[1].dy), imgLib.Point(corners[3].dx, corners[3].dy)]);
    List<imgLib.Point> DLTriangleTexture = [2, 3, 0]
        .map((i) => imgLib.Point(
            corners[i].dx / displayW * imgW, corners[i].dy / displayH * imgH))
        .toList();
    List<imgLib.Point> URTriangleResult = List.from([
      imgLib.Point(0, 0),
      imgLib.Point(a4Width, 0),
      imgLib.Point(a4Width, a4Height)
    ]);
    List<imgLib.Point> DLTriangleResult = List.from([
      imgLib.Point(a4Width, a4Height),
      imgLib.Point(0, a4Height),
      imgLib.Point(0, 0)
    ]);
    // TriangleTexturer tt = TriangleTexturer(photo, a4, URTriangleTexture, URTriangleResult);
    TriangleTexturer tt = TriangleTexturer(
        imageHistory.last, a4, URTriangleTexture, URTriangleResult);

    tt.texture();

    tt.setTriangles(DLTriangleTexture, DLTriangleResult);
    tt.texture();

    setState(() {
      addToHistory(tt.getResult());
      corners = List.empty();
    });
  }

  void calcInvariant() {
    setState(() {
      addToHistory(ImageProcessor(imageHistory.last).getInvariant());
    });
  }

  void extend() {
    setState(() {
      addToHistory(
          AutoBoundingBoxScanner.getExpandedToDiagonals(imageHistory.last));
    });
  }

  void rotate() {
    setState(() {
      addToHistory(AutoBoundingBoxScanner.getBoundingAngle(imageHistory.last));
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
    loadImage('assets/binary1.jpg');
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
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              // child: RotatedBox(
              //   quarterTurns: 1,
              //   child: Image(
              //     image: displayImage(imageHistory.last),
              //   ),
              // ),
              child: Stack(
                children: [
                  Image(
                    key: _imageKey,
                    image: displayImage(imageHistory.last),
                  ),
                  if (corners.isNotEmpty)
                    FramingTool(
                      imageKey: _imageKey,
                      points: corners,
                      setCorners: (List<Offset> corners) {
                        setState(() {
                          this.corners = corners;
                        });
                      },
                    ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: toGreyscale,
                  child: Text("Greyscale"),
                ),
                // FloatingActionButton(
                //     onPressed: extendImage, child: Text("Extend")),
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
              ].map((e) => Flexible(flex: 1, child: e)).toList(),
            ),
            Row(
              children: <Widget>[
                FloatingActionButton(
                  onPressed: findCorners,
                  child: Text("Corners"),
                ),
                FloatingActionButton(
                  onPressed: crop,
                  child: Text("Crop"),
                ),
                FloatingActionButton(
                  onPressed: calcInvariant,
                  child: Text("Invariant"),
                ),
                FloatingActionButton(
                  onPressed: extend,
                  child: Text("extend"),
                ),
                FloatingActionButton(
                  onPressed: rotate,
                  child: Text("Rotate"),
                ),
                FloatingActionButton(
                  onPressed: undo,
                  child: Text("<-"),
                ),
                FloatingActionButton(
                  onPressed: saveImage,
                  child: Text("save"),
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
