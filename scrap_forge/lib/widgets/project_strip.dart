import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/product.dart';

class ProjectStrip extends StatefulWidget {
  Product product;
  ProjectStrip({super.key, required this.product});

  @override
  State<ProjectStrip> createState() => _ProjectStripState();
}

class _ProjectStripState extends State<ProjectStrip> {
  Widget thumbnail = SvgPicture.asset(
    'assets/image-placeholder.svg',
    fit: BoxFit.fill,
  );

  Future<void> getImage() async {
    String? data;
    if (widget.product.photos.isEmpty) {
      return;
    }

    data = widget.product.photos.first.imgData;
    if (data != null) {
      Uint8List bytes = base64Decode(data);
      setState(() {
        thumbnail = Image(image: MemoryImage(bytes));
      });
    }
    return;

    // String dir = (await getApplicationDocumentsDirectory()).path;
    // File file = File('$dir/$imagePath');
  }

  Text displayName() {
    String name = "Twój wspaniały projekt";
    if (widget.product.name != null) {
      name = widget.product.name!;
    }
    return Text(
      name,
      textScaleFactor: 1.2,
    );
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: thumbnail,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: displayName(),
          ),
        ],
      ),
    );
  }
}
