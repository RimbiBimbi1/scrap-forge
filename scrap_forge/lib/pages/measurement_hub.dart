import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/db_entities/appSettings.dart';
import 'package:scrap_forge/pages/framing.dart';

class MeasurementHub extends StatefulWidget {
  final MeasurementToolQuality framingQuality;
  final MeasurementToolQuality boundingQuality;
  const MeasurementHub({
    super.key,
    this.framingQuality = MeasurementToolQuality.medium,
    this.boundingQuality = MeasurementToolQuality.medium,
  });

  @override
  State<MeasurementHub> createState() => _MeasurementHubState();
}

Future<Uint8List> pickImage({bool fromCamera = true}) async {
  ImageSource source = ImageSource.camera;
  if (!fromCamera) {
    source = ImageSource.gallery;
  }
  XFile? file = await ImagePicker().pickImage(source: source);
  if (file != null) {
    Uint8List bytes = await file.readAsBytes();
    return bytes;
  }

  return Uint8List(0);
}

class _MeasurementHubState extends State<MeasurementHub> {
  bool chooseFormat = false;
  SheetFormat sheetFormat = SheetFormat.a4;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Map arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    return Scaffold(
      // backgroundColor: Colors.grey[900],
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
          firstChild: const Text("Wybierz zdjęcie"),
          secondChild: Row(
            children: [SheetFormat.a5, SheetFormat.a4, SheetFormat.a3]
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
          child: SizedBox(
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
                      Uint8List picked = await pickImage(fromCamera: false);
                      if (context.mounted && picked.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FramingPage(
                                picked: picked,
                                sheetFormat: sheetFormat,
                                framingQuality: widget.framingQuality,
                                boundingQuality: widget.boundingQuality,
                                onBoundingBoxConfirmed:
                                    arguments['onBoundingBoxConfirmed']),
                          ),
                        );
                      }
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
                      Uint8List picked = await pickImage(fromCamera: true);
                      if (context.mounted && picked.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FramingPage(
                              picked: picked,
                              sheetFormat: sheetFormat,
                              framingQuality: widget.framingQuality,
                              boundingQuality: widget.boundingQuality,
                              onBoundingBoxConfirmed:
                                  arguments['onBoundingBoxConfirmed'],
                            ),
                          ),
                        );
                      }
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
