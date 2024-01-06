import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrap_forge/db_entities/product.dart';

class ProductStripSmall extends StatefulWidget {
  Product product;

  ProductStripSmall({
    super.key,
    required this.product,
  });

  @override
  State<ProductStripSmall> createState() => _ProductStripSmallState();
}

class _ProductStripSmallState extends State<ProductStripSmall> {
  Widget thumbnail = SvgPicture.asset(
    'assets/image-placeholder.svg',
    fit: BoxFit.fill,
  );

  void getImage() {
    String? data;

    if (widget.product.photos.isEmpty) {
      return;
    }

    data = widget.product.photos.first;
    Uint8List bytes = base64Decode(data);
    setState(() {
      thumbnail = Image(image: MemoryImage(bytes));
    });
    return;
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
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        color: theme.colorScheme.secondary,
      ),
      child: TextButton(
        onPressed: () async {
          await Navigator.pushNamed(context, "/product",
              arguments: {'productData': widget.product});
        },
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: thumbnail,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: displayName(),
            ),
          ],
        ),
      ),
    );
  }
}
