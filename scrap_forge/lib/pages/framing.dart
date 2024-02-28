import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/measure_tool/corner_scanner.dart';
import 'package:scrap_forge/measure_tool/framing_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor.dart';
import 'package:scrap_forge/pages/Loading.dart';
import 'dart:isolate';

import 'package:scrap_forge/pages/bounding.dart';
import 'package:scrap_forge/widgets/dialogs/format_selection_menu.dart';

class FramingPage extends StatefulWidget {
  final Uint8List picked;
  final SheetFormat sheetFormat;
  final Function(List<double>)? onBoundingBoxConfirmed;
  final MeasurementToolQuality framingQuality;
  final MeasurementToolQuality boundingQuality;
  final Map<String, SheetFormat> availableSheetFormats;
  const FramingPage({
    super.key,
    required this.picked,
    this.sheetFormat = SheetFormat.a4,
    this.onBoundingBoxConfirmed,
    this.framingQuality = MeasurementToolQuality.medium,
    this.boundingQuality = MeasurementToolQuality.medium,
    required this.availableSheetFormats,
  });

  @override
  State<FramingPage> createState() => _FramingPageState();
}

class _FramingPageState extends State<FramingPage> {
  Uint8List displayed = Uint8List(0);

  imgLib.Image image = imgLib.Image.empty();
  bool chooseFormat = false;
  SheetFormat sheetFormat = SheetFormat.a4;

  Future<dynamic>? sheetCorners;
  Future<dynamic>? detectedCorners;

  @override
  void initState() {
    super.initState();

    sheetFormat = widget.sheetFormat;
    displayed = widget.picked;

    image = imgLib.decodeJpg(widget.picked) ?? imgLib.Image.empty();

    sheetCorners = isolateTask(
        detectSheetIsolated, [widget.picked, widget.framingQuality]);
  }

  void resetCorners() {
    setState(() {});
  }

  Widget displayImage(double w, double h) {
    return Center(
      child: SizedBox(
        width: w,
        height: h,
        child: Image(
          fit: BoxFit.scaleDown,
          image: MemoryImage(
            displayed,
          ),
        ),
      ),
    );
  }

  Future<void> _displayFormatMenu() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return FormatSelectionMenu(
          formatOptions: widget.availableSheetFormats,
          currentFormat: sheetFormat,
          setFormat: (value) {
            setState(() {
              sheetFormat = value;
            });
          },
        );
      },
    );
  }

  List<Offset> organizeCorners(List<Offset> corners) {
    //Find corner nearest to (0,0)
    int closestCorner = 0;
    double minDistance = double.infinity;
    for (final (i, corner) in corners.indexed) {
      if (corner.distance > minDistance) {
        minDistance = corner.distance;
        closestCorner = i;
      }
    }
    //Arrange the points so the first one is the closest to (0,0)
    List<Offset> organized = corners.indexed
        .map((c) => corners[(c.$1 - closestCorner) % 4])
        .toList();

    //If the sheet is sideways, switch two of the corners to rotate it
    double distanceSq01 = (organized[1] - organized[0]).distance;
    double distanceSq03 = (organized[3] - organized[0]).distance;
    if (distanceSq01 > distanceSq03) {
      organized = organized.indexed.map((i) {
        if (i.$1 % 2 == 0) {
          return organized[(i.$1 + 2) % 4];
        }
        return i.$2;
      }).toList();
    }

    return organized;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Zaznacz rogi kartki"),
        actions: [
          TextButton(
              onPressed: _displayFormatMenu,
              child: Text(
                sheetFormat.name,
                style: const TextStyle(color: Colors.white),
              ))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: FutureBuilder(
            future: sheetCorners,
            builder: (context, snapshot) {
              double maxDisplayW = MediaQuery.of(context).size.width * 0.90;
              double maxDisplayH = MediaQuery.of(context).size.height * 0.80;

              if (snapshot.connectionState == ConnectionState.done) {
                double imgW = image.width.toDouble();
                double imgH = image.height.toDouble();

                double displayH = min(imgH * (maxDisplayW / imgW), maxDisplayH);
                double displayW = imgW * (displayH / imgH);

                List<Offset> corners = (snapshot.data as List<Offset>)
                    .map((e) => Offset(e.dx * displayW, e.dy * displayH))
                    .toList();

                return FramingTool(
                  size: Size(displayW, displayH),
                  displayImage: displayImage,
                  points: corners,
                  resetPoints: resetCorners,
                  setCorners: (adjustedCorners) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BoundingPage(
                              picked: widget.picked,
                              corners: organizeCorners(adjustedCorners)
                                  .map((e) =>
                                      Offset(e.dx / displayW, e.dy / displayH))
                                  .toList(),
                              sheetFormat: sheetFormat,
                              availableSheetFormats:
                                  widget.availableSheetFormats,
                              boundingQuality: widget.boundingQuality,
                              onBoundingBoxConfirmed:
                                  widget.onBoundingBoxConfirmed,
                            )));
                  },
                );
              } else {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(image: MemoryImage(widget.picked)),
                    const Loading(),
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

  List<Offset> corners = detectSheet(args[1], args[2]);

  Isolate.exit(resultPort, corners);
}

List<Offset> detectSheet(Uint8List picked, MeasurementToolQuality quality) {
  imgLib.Image? photo = imgLib.decodeJpg(picked);
  if (photo == null) {
    return List.empty();
  }

  if (photo.width > photo.height) {
    photo = imgLib.copyRotate(photo, angle: 90);
  }

  double h = quality.height.toDouble();
  double w = photo.width / photo.height * h;

  imgLib.Image processed =
      ImageProcessor.getBinaryShadowless(photo, height: h.round());

  CornerScanner cs = CornerScanner(processed);
  List<imgLib.Point> scanned = cs.scanForCorners();

  return scanned.map((e) => Offset(e.x / w, e.y / h)).toList();
}
