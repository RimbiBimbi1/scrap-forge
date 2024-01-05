import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imgLib;
import 'package:image_picker/image_picker.dart';
import 'package:scrap_forge/pages/framing_page.dart';

class MeasurementHub2 extends StatefulWidget {
  const MeasurementHub2({super.key});

  @override
  State<MeasurementHub2> createState() => _MeasurementHub2State();
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

class _MeasurementHub2State extends State<MeasurementHub2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        // title: AnimatedCrossFade(
        //   layoutBuilder: ((topChild, topChildKey, bottomChild, bottomChildKey) {
        //     return Stack(
        //       alignment: Alignment.center,
        //       children: <Widget>[
        //         Positioned(key: bottomChildKey, top: 0, child: bottomChild),
        //         Positioned(key: topChildKey, child: topChild),
        //       ],
        //     );
        //   }),
        //   firstChild: const Text("Pomiar"),
        //   secondChild: Row(
        //     children: [ASheetFormat.a5, ASheetFormat.a4, ASheetFormat.a3]
        //         .map((f) => TextButton(
        //               onPressed: () => setState(() {
        //                 chooseFormat = false;
        //                 sheetFormat = f;
        //               }),
        //               child: Text(
        //                 f.name,
        //                 style: const TextStyle(color: Colors.white),
        //               ),
        //             ))
        //         .toList(),
        //   ),
        //   crossFadeState: chooseFormat
        //       ? CrossFadeState.showSecond
        //       : CrossFadeState.showFirst,
        //   duration: const Duration(milliseconds: 200),
        // ),
        // actions: [
        //   TextButton(
        //       onPressed: () => setState(() {
        //             chooseFormat = !chooseFormat;
        //           }),
        //       child: Text(
        //         sheetFormat.name,
        //         style: const TextStyle(color: Colors.white),
        //       ))
        // ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          // padding: Ed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ElevatedButton(
                  onPressed: () async {
                    Uint8List picked = await pickImage(fromCamera: false);
                    if (context.mounted && picked.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FramingPage(picked: picked)),
                      );
                    }
                  },
                  child: const Text("Z galerii"),
                ),
              ),
              Flexible(
                child: ElevatedButton(
                  onPressed: () async {
                    Uint8List picked = await pickImage(fromCamera: true);
                    if (context.mounted && picked.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FramingPage(picked: picked)),
                      );
                    }
                  },
                  child: const Text("Z aparatu"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
