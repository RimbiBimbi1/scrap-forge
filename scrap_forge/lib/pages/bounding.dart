import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/measure_tool/auto_bounding_box_scanner.dart';
import 'package:scrap_forge/measure_tool/bounding_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor.dart';
import 'package:scrap_forge/measure_tool/triangle_texturer.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/utils/isolate_task.dart';

class BoundingPage extends StatefulWidget {
  final Uint8List pickedBytes;
  final imgLib.Image pickedImage;
  final List<Offset> corners;
  final SheetFormat sheetFormat;
  final Map<String, SheetFormat> availableSheetFormats;

  final MeasurementToolQuality boundingQuality;
  final Function(List<double>)? onBoundingBoxConfirmed;

  const BoundingPage({
    super.key,
    required this.pickedBytes,
    required this.pickedImage,
    required this.corners,
    this.sheetFormat = SheetFormat.a4,
    this.boundingQuality = MeasurementToolQuality.medium,
    this.onBoundingBoxConfirmed,
    required this.availableSheetFormats,
  });

  @override
  State<BoundingPage> createState() => _BoundingPageState();
}

class _BoundingPageState extends State<BoundingPage> {
  Future<dynamic>? boundingData;
  bool chooseFormat = false;
  SheetFormat sheetFormat = SheetFormat.a4;

  Widget displayImage(Uint8List image, double w, double h) {
    return Center(
      child: SizedBox(
        width: w,
        height: h,
        child: Image(
          fit: BoxFit.scaleDown,
          image: MemoryImage(
            image,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sheetFormat = widget.sheetFormat;

    boundingData = isolateTask(
      detectObjectIsolated,
      [
        widget.pickedImage,
        widget.corners,
        widget.sheetFormat,
        widget.boundingQuality,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Obramuj przedmiot"),
        actions: [
          AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text(
                sheetFormat.name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
            future: boundingData,
            builder: (context, snapshot) {
              double maxDisplayW = MediaQuery.of(context).size.width * 0.85;
              double maxDisplayH = MediaQuery.of(context).size.height * 0.75;

              if (snapshot.connectionState == ConnectionState.done) {
                List<dynamic> result = snapshot.data;
                imgLib.Image image = result[0] as imgLib.Image;
                List<Offset> cornersNormalized = result[1] as List<Offset>;
                int projectionAreaPixels = result[2] as int;

                double imgW = image.width.toDouble();
                double imgH = image.height.toDouble();

                double displayH = min(imgH * (maxDisplayW / imgW), maxDisplayH);
                double displayW = imgW * (displayH / imgH);

                List<Offset> corners = cornersNormalized
                    .map((e) => Offset(e.dx * displayW, e.dy * displayH))
                    .toList();

                return BoundingTool(
                    size: Size(displayW, displayH),
                    displayImage: (double w, double h) =>
                        displayImage(imgLib.encodeJpg(image), w, h),
                    points: corners,
                    projectionAreaPixels: projectionAreaPixels,
                    sheetFormat: sheetFormat,
                    onBoundingBoxConfirmed: widget.onBoundingBoxConfirmed);
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(image: MemoryImage(widget.pickedBytes)),
                    const Loading(
                      title: "Poszukiwanie przedmiotu...",
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

List<Offset> detectObjectIsolated(List<dynamic> args) {
  SendPort resultPort = args[0];
  imgLib.Image image = args[1];
  List<Offset> corners = args[2];
  SheetFormat sheetFormat = args[3];
  MeasurementToolQuality quality = args[4];

  imgLib.Image sheet = texture(
    image,
    corners,
    sheetFormat,
  );
  List<dynamic> result = detectBoundingBox(sheet, quality);
  corners = result[0] as List<Offset>;
  int projectionAreaPixels = result[1] as int;

  Isolate.exit(resultPort, [sheet, corners, projectionAreaPixels]);
}

imgLib.Image texture(
    imgLib.Image image, List<Offset> sheetCorners, SheetFormat format) {
  int sheetWpx = 420;
  int sheetHpx = (420 * (format.height / format.width)).round();
  double imgW = image.width.toDouble();
  double imgH = image.height.toDouble();

  imgLib.Image a4 = imgLib.Image(width: sheetWpx, height: sheetHpx);

  List<imgLib.Point> uRTriangleTexture = [0, 1, 2]
      .map((i) =>
          imgLib.Point(sheetCorners[i].dx * imgW, sheetCorners[i].dy * imgH))
      .toList();
  List<imgLib.Point> lLTriangleTexture = [2, 3, 0]
      .map((i) =>
          imgLib.Point(sheetCorners[i].dx * imgW, sheetCorners[i].dy * imgH))
      .toList();
  List<imgLib.Point> uRTriangleResult = List.from([
    imgLib.Point(0, 0),
    imgLib.Point(sheetWpx, 0),
    imgLib.Point(sheetWpx, sheetHpx)
  ]);
  List<imgLib.Point> lLTriangleResult = List.from([
    imgLib.Point(sheetWpx, sheetHpx),
    imgLib.Point(0, sheetHpx),
    imgLib.Point(0, 0)
  ]);
  TriangleTexturer tt =
      TriangleTexturer(image, a4, uRTriangleTexture, uRTriangleResult);

  tt.texture();

  tt.setTriangles(lLTriangleTexture, lLTriangleResult);
  tt.texture();

  imgLib.Image sheetCropped = tt.getResult();

  return sheetCropped;
}

List<dynamic> detectBoundingBox(
  imgLib.Image sheetImage,
  MeasurementToolQuality quality,
) {
  imgLib.Image binary = ImageProcessor.getBinaryShadowless(
    sheetImage,
    height: quality.height.toInt(),
  );

  int projectionAreaPixels = binary
      .getBytes()
      .reduce((value, element) => (element == 0) ? value += 1 : value);

  binary = ImageProcessor.getBinaryInversed(binary);

  double imgW = binary.width.toDouble();
  double imgH = binary.height.toDouble();

  List<imgLib.Point> scanned = AutoBoundingBoxScanner.getBoundingBox(binary);

  List<Offset> corners =
      scanned.map((e) => Offset(e.x / imgW, e.y / imgH)).toList();

  return [corners, projectionAreaPixels];
}
