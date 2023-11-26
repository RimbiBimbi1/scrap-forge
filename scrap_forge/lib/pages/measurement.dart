import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/measure_tool/auto_bounding_box_scanner.dart';
import 'package:scrap_forge/measure_tool/bounding_tool.dart';
import 'package:scrap_forge/measure_tool/corner_scanner.dart';
import 'package:scrap_forge/measure_tool/framing_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor2.dart';
import 'package:scrap_forge/measure_tool/triangle_texturer.dart';

class Measurement extends StatefulWidget {
  // final ThemeData themeData;
  Uint8List? photo;
  bool fastMode;

  Measurement({
    super.key,
    this.photo,
    this.fastMode = false,
    // required this.themeData,
  });

  @override
  State<Measurement> createState() => _MeasurementState();
}

class _MeasurementState extends State<Measurement> {
  imgLib.Image? photo;
  imgLib.Image? displayed;
  int phase = 0;
  /*Phases:
    0: image loading
    1: image loaded in, scanning for the sheet
    2: sheet found, scanning for the item
  */

  final sheetWmm = 210;
  final sheetHmm = 297;
  final sheetWpx = 840;
  final sheetHpx = 1188;

  bool sheetScanning = false;
  List<Offset> sheetCorners = List.empty();
  List<Offset> boundingCorners = List.empty();

  GlobalKey _imageKey = GlobalKey();
  GlobalKey<State<FramingTool>> _framingToolKey = GlobalKey();

  Future<void> getImageFromCamera() async {
    ByteData data = await rootBundle.load("assets/aw_r.jpg");
    imgLib.Image? img = imgLib.decodeJpg(data.buffer.asUint8List());
    if (img != null) {
      setState(
        () {
          photo = imgLib.Image.from(img);
          displayed = imgLib.Image.from(img);
          phase = 1;
        },
      );
    }
    // XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    // if (image != null) {
    //   Uint8List bytes = await image.readAsBytes();
    //   // ProductDTO copy = ProductDTO.copy(edited);
    //   imgLib.Image? img = imgLib.decodeJpg(bytes);
    //   if (img != null) {
    //     setState(() {
    //       displayed = imgLib.Image.from(img);
    //       photo = imgLib.Image.from(img);
    //       phase = 1;
    //     });
    //   }
    // }
  }

  MemoryImage displayImage(imgLib.Image image) {
    List<int>? withHeader = imgLib.encodeJpg(image);
    return MemoryImage(Uint8List.fromList(withHeader));
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
    Size displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    double displayW = displaySize.width;
    double displayH = displaySize.height;

    List<Offset> corners = scanned
        .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
        .toList();

    setState(() {
      phase = 2;
      sheetCorners = corners;
    });
  }

  void texture(List<Offset> sheetCorners) {
    double imgW = photo!.width.toDouble();
    double imgH = photo!.height.toDouble();
    Size displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    double displayW = displaySize.width;
    double displayH = displaySize.height;

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
    TriangleTexturer tt =
        TriangleTexturer(photo!, a4, URTriangleTexture, URTriangleResult);

    tt.texture();

    tt.setTriangles(DLTriangleTexture, DLTriangleResult);
    tt.texture();

    imgLib.Image sheetCropped = tt.getResult();

    imgLib.Image binary = getBinaryShadowless(sheetCropped);

    int projectionAreaPixels = binary
        .getBytes()
        .reduce((value, element) => (element == 0) ? value++ : value);

    binary = ImageProcessor.getBinaryInversed(binary);

    List<imgLib.Point> scanned = AutoBoundingBoxScanner.getBoundingBox(binary);

    imgW = binary.width.toDouble();
    imgH = binary.height.toDouble();
    // displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    // displayW = displaySize.width;
    // displayH = displaySize.height;

    List<Offset> corners = scanned
        .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
        .toList();

    setState(() {
      phase = 4;

      displayed = sheetCropped;
      boundingCorners = corners;
    });
  }

  void forwardAction() {
    switch (phase) {
      case 0:
        break;
      case 1:
        detectSheet(photo!);
        break;
      case 2:
        setState(() {
          phase = 3;
        });
        break;
      case 3:
        texture(sheetCorners);
        break;
      case 4:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.photo != null) {
      imgLib.Image? img = imgLib.decodeJpg(widget.photo!);

      if (img != null) {
        setState(() {
          displayed = imgLib.Image.from(img);
          photo = imgLib.Image.from(img);
          phase = 1;
        });
      }
    } else {
      getImageFromCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(phase);
    imgLib.Image processed = imgLib.Image(width: 0, height: 0);

    Widget current = Container();
    // switch (phase) {
    //   case 0:
    //     current = Placeholder(
    //       child: Text("WCZYTYWANIE"),
    //     );
    //     break;
    //   case 1:
    //     process
    //     if (photo != null) {
    //       detectSheet(photo!);
    //     }
    //     break;
    //   case 2:
    //     if (photo != null) {
    //       CornerScanner cs = CornerScanner(processed);
    //       List<imgLib.Point> scanned = cs.scanForCorners();
    //       double imgW = processed.width.toDouble();
    //       double imgH = processed.height.toDouble();
    //       Size displaySize = _imageKey.currentContext?.size ?? const Size(0, 0);
    //       double displayW = displaySize.width;
    //       double displayH = displaySize.height;

    //       List<Offset> corners = scanned
    //           .map((e) => Offset(e.x / imgW * displayW, e.y / imgH * displayH))
    //           .toList();

    //       print(corners);

    //       current = FramingTool(
    //         imageKey: _imageKey,
    //         points: sheetCorners,
    //         setCorners: (List<Offset> corners) {
    //           setState(() {
    //             this.sheetCorners = corners;
    //           });
    //         },
    //       );
    //     }
    //     break;
    //   case 4:
    //   case 5:
    //     current = BoundingTool(
    //       imageKey: _imageKey,
    //       points: List.empty(),
    //       setCorners: (List<Offset> boundingCorners) {
    //         setState(() {
    //           this.boundingCorners = boundingCorners;
    //         });
    //       },
    //     );
    //     break;
    // }
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          (phase == 2)
              ? "Zaznacz kartkę"
              : ((phase == 4) ? "Zaznacz przedmiot" : "Pomiar"),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.70,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    if (displayed != null)
                      Image(
                        key: _imageKey,
                        image: displayImage(displayed!),
                        fit: BoxFit.scaleDown,
                      ),
                    if (phase == 2 && sheetCorners.isNotEmpty)
                      FramingTool(
                        key: _framingToolKey,
                        imageKey: _imageKey,
                        points: sheetCorners,
                        setCorners: (List<Offset> corners) {
                          texture(corners);
                        },
                      ),
                    if (phase == 4 && boundingCorners.isNotEmpty)
                      BoundingTool(
                        key: _framingToolKey,
                        imageKey: _imageKey,
                        points: sheetCorners,
                        setCorners: (List<Offset> corners) {
                          setState(() {
                            this.boundingCorners = corners;
                          });
                        },
                      ),
                  ],
                ),
              ),
              if (phase == 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FloatingActionButton(
                        onPressed: () => setState(
                          () {
                            // phase -= 1;
                          },
                        ),
                        child: Text("<"),
                      ),
                      FloatingActionButton(
                        onPressed: () => setState(() {
                          detectSheet(photo!);
                        }),
                        child: Text(">"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
