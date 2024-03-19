import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/pages/framing.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/utils/isolate_task.dart';
import 'package:scrap_forge/widgets/dialogs/format_selection_menu.dart';
import 'package:image/image.dart' as imgLib;

class MeasurementHub extends StatefulWidget {
  final MeasurementToolQuality framingQuality;
  final MeasurementToolQuality boundingQuality;
  final SheetFormat sheetFormat;
  final Map<String, SheetFormat> availableSheetFormats;
  const MeasurementHub({
    super.key,
    this.framingQuality = MeasurementToolQuality.medium,
    this.boundingQuality = MeasurementToolQuality.medium,
    this.sheetFormat = SheetFormat.a4,
    required this.availableSheetFormats,
  });

  @override
  State<MeasurementHub> createState() => _MeasurementHubState();
}

class _MeasurementHubState extends State<MeasurementHub> {
  SheetFormat sheetFormat = SheetFormat.a4;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sheetFormat = widget.sheetFormat;
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      // backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Wybierz zdjęcie"),
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
          // padding: Ed,
          child: isLoading
              ? Loading(
                  title: "Wczytywanie zdjęcia...",
                )
              : SizedBox(
                  height: 350,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            side: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          onPressed: () async {
                            // Uint8List picked = await pickImage(fromCamera: false);
                            XFile? picked = await pickImage(fromCamera: false);
                            if (picked == null) return;
                            setState(() {
                              isLoading = true;
                            });
                            List<dynamic> reoriented = await isolateTask(
                                reorientImageIsolated, [picked]);
                            if (reoriented.isEmpty) return;

                            if (context.mounted && reoriented.isNotEmpty) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FramingPage(
                                    pickedBytes: reoriented[0] as Uint8List,
                                    pickedImage: reoriented[1] as imgLib.Image,
                                    sheetFormat: sheetFormat,
                                    availableSheetFormats:
                                        widget.availableSheetFormats,
                                    framingQuality: widget.framingQuality,
                                    boundingQuality: widget.boundingQuality,
                                    onBoundingBoxConfirmed:
                                        arguments['onBoundingBoxConfirmed'],
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 35,
                              ),
                              SizedBox(height: 10),
                              Text("Wybierz zdjęcie z galerii"),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            side: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          onPressed: () async {
                            XFile? picked = await pickImage(fromCamera: true);
                            if (picked == null) return;
                            setState(() {
                              isLoading = true;
                            });
                            List<dynamic> reoriented = await isolateTask(
                                reorientImageIsolated, [picked]);
                            if (reoriented.isEmpty) return;

                            if (context.mounted && reoriented.isNotEmpty) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FramingPage(
                                    pickedBytes: reoriented[0] as Uint8List,
                                    pickedImage: reoriented[1] as imgLib.Image,
                                    sheetFormat: sheetFormat,
                                    availableSheetFormats:
                                        widget.availableSheetFormats,
                                    framingQuality: widget.framingQuality,
                                    boundingQuality: widget.boundingQuality,
                                    onBoundingBoxConfirmed:
                                        arguments['onBoundingBoxConfirmed'],
                                  ),
                                ),
                              );
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 30,
                              ),
                              SizedBox(height: 10),
                              Text("Wykonaj zdjęcie aparatem"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

Future<XFile?> pickImage({bool fromCamera = true}) async {
  ImageSource source = ImageSource.camera;
  if (!fromCamera) {
    source = ImageSource.gallery;
  }
  XFile? file = await ImagePicker().pickImage(
      maxHeight: 1440, maxWidth: 1440, source: source, imageQuality: 80);

  // if (file != null) {
  //   Uint8List bytes = await file.readAsBytes();

  //   imgLib.Image? image = imgLib.decodeJpg(bytes);
  //   if (image != null && image.width > image.height) {
  //     image = imgLib.copyRotate(image, angle: 90);
  //     bytes = imgLib.encodeJpg(image);
  //   }

  //   return [bytes, image];
  // }

  return file;
}

Future<List> reorientImageIsolated(List<dynamic> args) async {
  SendPort resultPort = args[0];
  XFile? picked = args[1];

  if (picked == null) {
    Isolate.exit(resultPort, []);
  }

  List<dynamic> result = await reorientImage(picked);

  Isolate.exit(resultPort, result);
}

Future<List> reorientImage(XFile picked) async {
  // Uint8List bytes = await picked.readAsBytes();
  imgLib.Image? image = await imgLib.decodeJpgFile(picked.path);
  if (image == null) return [];
  if (image.width > image.height) {
    image = imgLib.copyRotate(image, angle: 90);
  }
  Uint8List bytes = imgLib.encodeJpg(image);
  return [bytes, image];
}
