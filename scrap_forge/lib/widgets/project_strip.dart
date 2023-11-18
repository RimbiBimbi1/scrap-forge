import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/product.dart';

class ProjectStrip extends StatefulWidget {
  Product product;
  ProjectStrip({super.key, required this.product});

  @override
  State<ProjectStrip> createState() => _ProjectStripState();
}

class _ProjectStripState extends State<ProjectStrip> {
  File? image;

  Future<void> getImage() async {
    String? imagePath;
    if (widget.product.photos.isEmpty) {
      return;
    }

    imagePath = widget.product.photos.first.path;
    if (imagePath == null) {
      return;
    }

    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/$imagePath');
    setState(() {
      image = file;
    });
  }

  Widget displayImage() {
    if (image == null) {
      return SvgPicture.asset(
        'assets/image-placeholder.svg',
        fit: BoxFit.fill,
      );
    }
    return Image.file(image!);
  }

  Text displayName() {
    String name = "Twój wspaniały projekt";
    if (widget.product.name != null) {
      name = widget.product.name!;
    }
    return Text(name);
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
            child: displayImage(),
            width: 60,
            height: 60,
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: displayName(),
            ),
          ),
        ],
      ),
    );
  }
}
