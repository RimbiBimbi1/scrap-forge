import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/measure_tool/auto_bounding_box_scanner.dart';
import 'package:scrap_forge/measure_tool/bounding_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor.dart';
import 'package:scrap_forge/measure_tool/triangle_texturer.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/utils/a_sheet_format.dart';

class BoundingPage extends StatefulWidget {
  final Uint8List picked;
  final List<Offset> corners;
  final ASheetFormat sheetFormat;
  final Function(List<double>)? onBoundingBoxConfirmed;

  const BoundingPage({
    super.key,
    required this.picked,
    required this.corners,
    this.sheetFormat = ASheetFormat.a4,
    this.onBoundingBoxConfirmed,
  });

  @override
  State<BoundingPage> createState() => _BoundingPageState();
}

class _BoundingPageState extends State<BoundingPage> {
  Future<dynamic>? boundingData;
  bool chooseFormat = false;
  ASheetFormat sheetFormat = ASheetFormat.a4;

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
    boundingData = isolateTask(detectSheetIsolated, [
      imgLib.decodeJpg(widget.picked) ?? imgLib.Image.empty(),
      widget.corners,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: AnimatedCrossFade(
          layoutBuilder: ((topChild, topChildKey, bottomChild, bottomChildKey) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(key: bottomChildKey, top: 0, child: bottomChild),
                Positioned(key: topChildKey, child: topChild),
              ],
            );
          }),
          firstChild: const Text("Obramuj przedmiot"),
          secondChild: Row(
            children: [ASheetFormat.a5, ASheetFormat.a4, ASheetFormat.a3]
                .map((f) => TextButton(
                      onPressed: () => setState(() {
                        chooseFormat = false;
                        sheetFormat = f;
                      }),
                      child: Text(
                        f.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
          ),
          crossFadeState: chooseFormat
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        actions: [
          TextButton(
              onPressed: () => setState(() {
                    chooseFormat = !chooseFormat;
                  }),
              child: Text(
                sheetFormat.name,
                style: const TextStyle(color: Colors.white),
              ))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          // padding: Ed,
          child: FutureBuilder(
            future: boundingData,
            builder: (context, snapshot) {
              double displayW = MediaQuery.of(context).size.width * 0.95;

              if (snapshot.connectionState == ConnectionState.done) {
                List<dynamic> result = snapshot.data;

                imgLib.Image image = result[0] as imgLib.Image;
                List<Offset> cornersNormalized = result[1] as List<Offset>;
                int projectionAreaPixels = result[2] as int;

                double imgW = image.width.toDouble();
                double imgH = image.height.toDouble();

                double displayH = imgH * (displayW / imgW);

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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SizedBox(
                    width: displayW,
                    child: Center(
                      child: Stack(
                        children: [
                          Image(image: MemoryImage(widget.picked)),
                          const Loading(),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

Future isolateTask(
    void Function(List<dynamic> tArgs) task, List<dynamic> args) async {
  final ReceivePort receivePort = ReceivePort();
  try {
    await Isolate.spawn(task, [receivePort.sendPort, ...args]);
  } on Object {
    receivePort.close();
  }

  final response = await receivePort.first;

  return response;
}

List<Offset> detectSheetIsolated(List<dynamic> args) {
  SendPort resultPort = args[0];

  imgLib.Image sheet = texture(args[1], args[2]);
  List<dynamic> result = detectBoundingBox(sheet);
  List<Offset> corners = result[0] as List<Offset>;
  int projectionAreaPixels = result[1] as int;

  Isolate.exit(resultPort, [sheet, corners, projectionAreaPixels]);
}

imgLib.Image texture(imgLib.Image photo, List<Offset> sheetCorners) {
  // phase = 'sheetConfirmed';
  const sheetWpx = 420;
  const sheetHpx = 594;
  double imgW = photo.width.toDouble();
  double imgH = photo.height.toDouble();

  // double displayW = MediaQuery.of(context).size.width * 0.95;
  // double displayH = imgH * (displayW / imgW);

  imgLib.Image a4 = imgLib.Image(width: sheetWpx, height: sheetHpx);

  List<imgLib.Point> URTriangleTexture = [0, 1, 2]
      .map((i) =>
          imgLib.Point(sheetCorners[i].dx * imgW, sheetCorners[i].dy * imgH))
      .toList();
  List<imgLib.Point> DLTriangleTexture = [2, 3, 0]
      .map((i) =>
          imgLib.Point(sheetCorners[i].dx * imgW, sheetCorners[i].dy * imgH))
      .toList();
  List<imgLib.Point> URTriangleResult = List.from([
    imgLib.Point(0, 0),
    imgLib.Point(sheetWpx, 0),
    imgLib.Point(sheetWpx, sheetHpx)
  ]);
  List<imgLib.Point> DLTriangleResult = List.from([
    imgLib.Point(sheetWpx, sheetHpx),
    imgLib.Point(0, sheetHpx),
    imgLib.Point(0, 0)
  ]);
  TriangleTexturer tt =
      TriangleTexturer(photo, a4, URTriangleTexture, URTriangleResult);

  tt.texture();

  tt.setTriangles(DLTriangleTexture, DLTriangleResult);
  tt.texture();

  imgLib.Image sheetCropped = tt.getResult();

  return sheetCropped;
}

List<dynamic> detectBoundingBox(imgLib.Image sheetImage) {
  imgLib.Image binary =
      ImageProcessor.getBinaryShadowless(sheetImage, height: 400);

  int projectionAreaPixels = binary
      .getBytes()
      .reduce((value, element) => (element == 0) ? value += 1 : value);

  binary = ImageProcessor.getBinaryInversed(binary);

  double imgW = binary.width.toDouble();
  double imgH = binary.height.toDouble();
  // displayH = imgH * (displayW / imgW);

  List<imgLib.Point> scanned = AutoBoundingBoxScanner.getBoundingBox(binary);

  List<Offset> corners =
      scanned.map((e) => Offset(e.x / imgW, e.y / imgH)).toList();

  return [corners, projectionAreaPixels];
}
