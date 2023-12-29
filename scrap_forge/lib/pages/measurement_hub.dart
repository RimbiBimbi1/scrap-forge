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
import 'package:scrap_forge/pages/loading.dart';

enum ASheetFormat {
  a5(name: 'A5', width: 148, height: 210),
  a4(name: 'A4', width: 210, height: 297),
  a3(name: 'A3', width: 297, height: 420);

  const ASheetFormat({
    required this.name,
    required this.width,
    required this.height,
  });

  final String name;
  final double width;
  final double height;
}

class MeasurementHub extends StatefulWidget {
  const MeasurementHub({super.key});

  @override
  State<MeasurementHub> createState() => _MeasurementHubState();
}

class _MeasurementHubState extends State<MeasurementHub> {
  final sheetWpx = 420;
  final sheetHpx = 594;

  bool chooseFormat = false;
  ASheetFormat sheetFormat = ASheetFormat.a4;

  String phase = "init";

  imgLib.Image originalPhoto = imgLib.Image(width: 200, height: 300);
  imgLib.Image displayed = imgLib.Image(width: 200, height: 300);
  imgLib.Image sheet = imgLib.Image(width: 210, height: 297);

  List<Offset> sheetCorners = List.empty();
  List<Offset> itemBoundingBox = List.empty();

  int projectionAreaPixels = 0;

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
      Uint8List bytes = await file.readAsBytes();
      imgLib.Image? image = imgLib.decodeJpg(bytes);
      if (image != null) {
        detectSheet(image);
      }
    }
  }

  imgLib.Image getBinaryShadowless(imgLib.Image photo) {
    const List<List<int>> Kx = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    const List<List<int>> Ky = [
      [1, 2, 1],
      [0, 0, 0],
      [-1, -2, -1]
    ];

    imgLib.Image processed = imgLib.copyResize(
      photo, height: 400,
      // height: (photo.height / 4).round(),
      // width: (photo.width / 4).round(),
    );

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
    if (photo.width > photo.height) {
      photo = imgLib.copyRotate(photo, angle: 90);
    }

    imgLib.Image processed = getBinaryShadowless(photo);

    CornerScanner cs = CornerScanner(processed);
    List<imgLib.Point> scanned = cs.scanForCorners();
    double imgW = processed.width.toDouble();
    double imgH = processed.height.toDouble();

    double displayW = MediaQuery.of(context).size.width * 0.95;
    double displayH = imgH * (displayW / imgW);

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

    double displayW = MediaQuery.of(context).size.width * 0.95;
    double displayH = imgH * (displayW / imgW);

    imgLib.Image a4 = imgLib.Image(width: sheetWpx, height: sheetHpx);

    List<imgLib.Point> URTriangleTexture = [0, 1, 2]
        .map((i) => imgLib.Point(sheetCorners[i].dx / displayW * imgW,
            sheetCorners[i].dy / displayH * imgH))
        .toList();
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
    TriangleTexturer tt = TriangleTexturer(
        originalPhoto, a4, URTriangleTexture, URTriangleResult);

    tt.texture();

    tt.setTriangles(DLTriangleTexture, DLTriangleResult);
    tt.texture();

    imgLib.Image sheetCropped = tt.getResult();

    imgLib.Image binary = getBinaryShadowless(sheetCropped);

    int projectionAreaPixels = binary
        .getBytes()
        .reduce((value, element) => (element == 0) ? value += 1 : value);

    binary = ImageProcessor.getBinaryInversed(binary);

    imgW = binary.width.toDouble();
    imgH = binary.height.toDouble();
    displayH = imgH * (displayW / imgW);

    List<imgLib.Point> scanned = AutoBoundingBoxScanner.getBoundingBox(binary);

    List<Offset> corners = scanned
        .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
        .toList();

    setState(() {
      this.projectionAreaPixels = projectionAreaPixels;
      itemBoundingBox = corners;
      sheet = sheetCropped;
      displayed = sheetCropped;
      // displayed = binary;
      phase = 'boundingBoxDetected';
    });
  }

  Widget displayImage(double w, double h) {
    List<int>? withHeader = imgLib.encodeJpg(displayed);
    return Center(
      child: SizedBox(
        width: w,
        height: h,
        child: Image(
          fit: BoxFit.scaleDown,
          image: MemoryImage(
            Uint8List.fromList(withHeader),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double imgW = displayed.width.toDouble();
    double imgH = displayed.height.toDouble();

    double displayW = MediaQuery.of(context).size.width * 0.95;
    double displayH = imgH * (displayW / imgW);

    Widget renderContent() {
      switch (phase) {
        case 'boundingBoxDetected':
          return BoundingTool(
            points: itemBoundingBox,
            displayImage: displayImage,
            sheetFormat: sheetFormat,
            size: Size(displayW, displayH),
            projectionAreaPixels: this.projectionAreaPixels,
          );
        case 'sheetDetected':
          return FramingTool(
            points: sheetCorners,
            displayImage: displayImage,
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
                  onPressed: () async {
                    await pickImage(fromCamera: false);
                  },
                  child: const Text("Z galerii"),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () async {
                    await pickImage(fromCamera: true);
                  },
                  child: const Text("Z aparatu"),
                ),
              ),
            ],
          );
      }
      return const Placeholder();
    }

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
          firstChild: const Text("Pomiar"),
          secondChild: Row(
            children: [ASheetFormat.a5, ASheetFormat.a4, ASheetFormat.a3]
                .map((f) => TextButton(
                      onPressed: () => setState(() {
                        chooseFormat = false;
                        sheetFormat = f;
                      }),
                      child: Text(
                        f.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                .toList(),
          ),
          crossFadeState: chooseFormat
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 200),
        ),
        actions: [
          TextButton(
              onPressed: () => setState(() {
                    chooseFormat = !chooseFormat;
                  }),
              child: Text(
                sheetFormat.name,
                style: TextStyle(color: Colors.white),
              ))
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
