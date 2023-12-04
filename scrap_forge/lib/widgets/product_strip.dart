import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrap_forge/db_entities/product.dart';

class ProductStrip extends StatefulWidget {
  Product product;
  bool asMaterial;
  ProductStrip({super.key, required this.product, this.asMaterial = false});

  @override
  State<ProductStrip> createState() => _ProductStripState();
}

class _ProductStripState extends State<ProductStrip> {
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
        thumbnail = Image(
          fit: BoxFit.fill,
          image: MemoryImage(bytes),
        );
      });
    }
    return;

    // String dir = (await getApplicationDocumentsDirectory()).path;
    // File file = File('$dir/$imagePath');
  }

  Widget displayHeader() {
    TextStyle textStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSecondary);
    String name = "Twój wspaniały projekt";
    if (widget.product.name != null) {
      name = widget.product.name!;
    }
    return Text(
      name,
      textScaleFactor: 1.25,
      style: textStyle,
    );
  }

  Widget displayBody() {
    TextStyle textStyle =
        TextStyle(color: Theme.of(context).colorScheme.onBackground);
    if (!widget.asMaterial) {
      StringBuffer sb = StringBuffer();
      if (widget.product.description != null) {
        for (String line in (widget.product.description!.split('\\n'))) {
          sb.write(line + "\n");
        }
      }

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(sb.toString(), style: textStyle),
        ),
      );
    } else {
      return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Długość: ${widget.product.length}mm"),
                Text("Szerokość: ${widget.product.width}mm"),
                Text("Wysokość: ${widget.product.height}mm"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Użyte: ${widget.product.consumed ??= 0}"),
                    Text("Na stanie: ${widget.product.available ??= 0}"),
                    Text("Potrzebne: ${widget.product.needed ??= 0}"),
                  ],
                )
              ],
            )),
      );
    }
  }

  Widget displayFooter() {
    TextStyle textStyle =
        TextStyle(color: Theme.of(context).colorScheme.onBackground);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        (widget.product.addedTimestamp != null)
            ? Text(
                "Dodano: ${DateTime.fromMillisecondsSinceEpoch(1000 * widget.product.addedTimestamp!).toString().substring(0, 10)}",
                maxLines: 1,
                style: textStyle,
              )
            : Container(),
        (!widget.asMaterial && widget.product.finishedTimestamp != null)
            ? Text(
                "Ukończono: ${DateTime.fromMillisecondsSinceEpoch(1000 * widget.product.finishedTimestamp!).toString().substring(0, 10)}",
                maxLines: 1,
                style: textStyle,
              )
            : Container()
        // Text(
        // "Ukończono: ${widget.product.addedTimestamp != null ? DateTime.fromMicrosecondsSinceEpoch(widget.product.addedTimestamp!) : "?"}"),
      ],
    );
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 2, color: Colors.white10))),
      child: TextButton(
        onPressed: () {},
        child: SizedBox(
          height: 125,
          child: Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: thumbnail,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        displayHeader(),
                        displayBody(),
                        displayFooter()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
