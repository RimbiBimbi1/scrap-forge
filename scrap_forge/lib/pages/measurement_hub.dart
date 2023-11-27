import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/measure_tool/auto_bounding_box_scanner.dart';
import 'package:scrap_forge/measure_tool/bounding_tool.dart';
import 'package:scrap_forge/measure_tool/corner_scanner.dart';
import 'package:scrap_forge/measure_tool/framing_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor.dart';
import 'package:scrap_forge/measure_tool/triangle_texturer.dart';

class MeasurementHub extends StatefulWidget {
  const MeasurementHub({super.key});

  @override
  State<MeasurementHub> createState() => _MeasurementHubState();
}

class _MeasurementHubState extends State<MeasurementHub> {
  final sheetWmm = 210;
  final sheetHmm = 297;
  final sheetWpx = 840;
  final sheetHpx = 1188;

  String phase = "init";

  imgLib.Image originalPhoto = imgLib.Image(width: 200, height: 300);
  imgLib.Image displayed = imgLib.Image(width: 200, height: 300);
  imgLib.Image sheet = imgLib.Image(width: 210, height: 297);

  List<Offset> sheetCorners = List.empty();
  List<Offset> itemBoundingBox = List.empty();

  @override
  void initState() {
    super.initState();
  }

  pickImage({bool fromCamera = true}) async {
    ImageSource source = ImageSource.camera;
    if (!fromCamera) {
      source = ImageSource.gallery;
    }
    XFile? file = await ImagePicker().pickImage(source: source);
    if (file != null) {
      ByteData data = await rootBundle.load("assets/mw_r_1.jpg");
      imgLib.Image? image = imgLib.decodeJpg(data.buffer.asUint8List());

      // Uint8List bytes = await file.readAsBytes();
      // imgLib.Image? image = imgLib.decodeJpg(bytes);
      if (image != null) {
        detectSheet(image);

        // setState(() {
        //   originalPhoto = image;
        //   phase = "sheetDetection";
        // });
      }
    }
  }

  imgLib.Image getBinaryShadowless(imgLib.Image photo) {
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

    imgLib.Image processed = imgLib.copyResize(photo,
        width: (photo.width / 4).round(), height: (photo.height / 4).round());

    processed = ImageProcessor.getInvariant(processed);
    processed = ImageProcessor.getGaussianBlurred(processed);

    List<List<double>> xSobel =
        ImageProcessor.getDirectionalSobel(processed, Kx);
    List<List<double>> ySobel =
        ImageProcessor.getDirectionalSobel(processed, Ky);

    processed = ImageProcessor.getSobel(processed, xSobel, ySobel);

    List<List<double>> direction =
        ImageProcessor.getSobelDirection(processed, xSobel, ySobel);
    processed = ImageProcessor.getNonMaxSuppressed(processed, direction);
    processed = ImageProcessor.getDoubleThresholded(processed);
    processed = ImageProcessor.getHysteresised(processed);
    processed = ImageProcessor.getEroded(processed);
    processed = ImageProcessor.getEroded(processed);
    processed = ImageProcessor.getEroded(processed);
    processed = ImageProcessor.getFloodfilled(processed);
    processed = ImageProcessor.getDilated(processed);
    processed = ImageProcessor.getDilated(processed);
    processed = ImageProcessor.getDilated(processed);

    return processed;
  }

  void detectSheet(imgLib.Image photo) {
    imgLib.Image processed = getBinaryShadowless(photo);

    CornerScanner cs = CornerScanner(processed);
    List<imgLib.Point> scanned = cs.scanForCorners();
    double imgW = processed.width.toDouble();
    double imgH = processed.height.toDouble();

    double displayH = MediaQuery.of(context).size.height * 0.75;
    double displayW = (imgW * displayH) / imgH;

    List<Offset> corners = scanned
        .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
        .toList();

    setState(() {
      phase = "sheetDetected";
      sheetCorners = corners;
      originalPhoto = photo;
      displayed = photo;
    });
  }

  void texture(List<Offset> sheetCorners) {
    // phase = 'sheetConfirmed';
    double imgW = originalPhoto.width.toDouble();
    double imgH = originalPhoto.height.toDouble();

    double displayH = MediaQuery.of(context).size.height * 0.75;
    double displayW = (imgW * displayH) / imgH;

    imgLib.Image a4 = imgLib.Image(width: sheetWpx, height: sheetHpx);

    List<imgLib.Point> URTriangleTexture = [0, 1, 2]
        .map((i) => imgLib.Point(sheetCorners[i].dx / displayW * imgW,
            sheetCorners[i].dy / displayH * imgH))
        .toList();
    // List<imgLib.Point> ULTriangle = List.from([imgLib.Point(corners[0].dx, corners[0].dy), imgLib.Point(corners[1].dx, corners[1].dy), imgLib.Point(corners[3].dx, corners[3].dy)]);
    List<imgLib.Point> DLTriangleTexture = [2, 3, 0]
        .map((i) => imgLib.Point(sheetCorners[i].dx / displayW * imgW,
            sheetCorners[i].dy / displayH * imgH))
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
    // TriangleTexturer tt = TriangleTexturer(photo, a4, URTriangleTexture, URTriangleResult);
    TriangleTexturer tt = TriangleTexturer(
        originalPhoto, a4, URTriangleTexture, URTriangleResult);

    tt.texture();

    tt.setTriangles(DLTriangleTexture, DLTriangleResult);
    tt.texture();

    imgLib.Image sheetCropped = tt.getResult();

    imgLib.Image binary = getBinaryShadowless(sheetCropped);

    int projectionAreaPixels = binary
        .getBytes()
        .reduce((value, element) => (element == 0) ? value++ : value);

    binary = ImageProcessor.getBinaryInversed(binary);

    imgW = binary.width.toDouble();
    imgH = binary.height.toDouble();
    displayH = MediaQuery.of(context).size.height * 0.75;
    displayW = (imgW * displayH) / imgH;

    List<imgLib.Point> scanned = AutoBoundingBoxScanner.getBoundingBox(binary);

    // displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    // displayW = displaySize.width;
    // displayH = displaySize.height;

    List<Offset> corners = scanned
        .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
        .toList();

    setState(() {
      itemBoundingBox = corners;
      sheet = sheetCropped;
      displayed = sheetCropped;
      phase = 'boundingBoxDetected';
    });
  }

  @override
  Widget build(BuildContext context) {
    double imgW = displayed.width.toDouble();
    double imgH = displayed.height.toDouble();

    double displayH = MediaQuery.of(context).size.height * 0.75;
    double displayW = (imgW * displayH) / imgH;

    Image displayImage(imgLib.Image image) {
      List<int>? withHeader = imgLib.encodeJpg(image);
      return Image(image: MemoryImage(Uint8List.fromList(withHeader)));
    }

    Widget renderContent() {
      switch (phase) {
        case 'boundingBoxDetected':
          return BoundingTool(
            points: itemBoundingBox,
            image: displayImage(displayed),
            size: Size(displayW, displayH),
            setCorners: (List<Offset> corners) {},
          );
        case 'sheetDetected':
          return FramingTool(
            points: sheetCorners,
            image: displayImage(displayed),
            size: Size(displayW, displayH),
            setCorners: (List<Offset> corners) {
              texture(corners);
            },
          );
        case 'init':
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () => pickImage(fromCamera: false),
                  child: Text("Z galerii"),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () => pickImage(fromCamera: true),
                  child: Text("Z aparatu"),
                ),
              ),
            ],
          );
      }
      return Placeholder();
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Moja kuźnia"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          // padding: Ed,
          child: renderContent(),
        ),
      ),
    );
  }
}
