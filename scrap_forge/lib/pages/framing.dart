import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/db_entities/appSettings.dart';
import 'package:scrap_forge/measure_tool/corner_scanner.dart';
import 'package:scrap_forge/measure_tool/framing_tool.dart';
import 'package:scrap_forge/measure_tool/image_processor.dart';
import 'package:scrap_forge/pages/Loading.dart';
import 'dart:isolate';

import 'package:scrap_forge/pages/bounding.dart';
import 'package:scrap_forge/utils/a_sheet_format.dart';

class FramingPage extends StatefulWidget {
  final Uint8List picked;
  final ASheetFormat sheetFormat;
  final Function(List<double>)? onBoundingBoxConfirmed;
  final MeasurementToolQuality framingQuality;
  final MeasurementToolQuality boundingQuality;
  const FramingPage({
    super.key,
    required this.picked,
    this.sheetFormat = ASheetFormat.a4,
    this.onBoundingBoxConfirmed,
    this.framingQuality = MeasurementToolQuality.medium,
    this.boundingQuality = MeasurementToolQuality.medium,
  });

  @override
  State<FramingPage> createState() => _FramingPageState();
}

class _FramingPageState extends State<FramingPage> {
  Uint8List displayed = Uint8List(0);

  imgLib.Image image = imgLib.Image.empty();
  bool chooseFormat = false;
  ASheetFormat sheetFormat = ASheetFormat.a4;

  Future<dynamic>? sheetCorners;

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

  @override
  void initState() {
    super.initState();

    sheetFormat = widget.sheetFormat;
    displayed = widget.picked;

    image = imgLib.decodeJpg(widget.picked) ?? imgLib.Image.empty();

    sheetCorners = isolateTask(
        detectSheetIsolated, [widget.picked, widget.framingQuality]);
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
          firstChild: const Text("Zaznacz rogi kartki"),
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
            future: sheetCorners,
            builder: (context, snapshot) {
              double displayW = MediaQuery.of(context).size.width * 0.95;

              if (snapshot.connectionState == ConnectionState.done) {
                double imgW = image.width.toDouble();
                double imgH = image.height.toDouble();

                double displayH = imgH * (displayW / imgW);

                List<Offset> corners = (snapshot.data as List<Offset>)
                    .map((e) => Offset(e.dx * displayW, e.dy * displayH))
                    .toList();

                return FramingTool(
                  size: Size(displayW, displayH),
                  displayImage: displayImage,
                  points: corners,
                  setCorners: (adjustedCorners) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BoundingPage(
                              picked: widget.picked,
                              corners: adjustedCorners
                                  .map((e) =>
                                      Offset(e.dx / displayW, e.dy / displayH))
                                  .toList(),
                              sheetFormat: sheetFormat,
                              boundingQuality: widget.boundingQuality,
                              onBoundingBoxConfirmed:
                                  widget.onBoundingBoxConfirmed,
                            )));
                  },
                );
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
