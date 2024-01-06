import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/dimension_formatter.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';

class ProductStrip extends StatefulWidget {
  Product product;
  bool asMaterial;
  VoidCallback? onLongPress;
  VoidCallback? onPressed;
  ProductStrip({
    super.key,
    required this.product,
    this.asMaterial = false,
    this.onLongPress,
    this.onPressed,
  });

  @override
  State<ProductStrip> createState() => _ProductStripState();
}

class _ProductStripState extends State<ProductStrip> {
  Widget? thumbnail;

  Future<void> getImage() async {
    String? data;

    if (widget.product.photos.isEmpty) {
      return;
    }

    data = widget.product.photos.first;
    Uint8List bytes = base64Decode(data);
    setState(() {
      thumbnail = Image(
        fit: BoxFit.fill,
        image: MemoryImage(bytes),
      );
    });
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
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            StringMultiliner.multiline(widget.product.description).toString(),
            style: textStyle,
            textAlign: TextAlign.justify,
          ),
        ),
      );
    } else {
      return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(DimensionFormatter.toLxWxH(widget.product.dimensions)),
                // if (widget.product.dimensions?.length != null)
                //   Text("Długość: ${widget.product.dimensions?.length}mm"),
                // if (widget.product.dimensions?.width != null)
                //   Text("Szerokość: ${widget.product.dimensions?.width}mm"),
                // if (widget.product.dimensions?.height != null)
                //   Text("Wysokość: ${widget.product.dimensions?.height}mm"),
                Divider(),
                Text("Wykorzystane: ${widget.product.consumed ?? 0}"),
                Text("Na stanie: ${widget.product.available ?? 0}"),
                Text("Potrzebne: ${widget.product.needed ?? 0}")
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
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: Colors.white10,
          ),
        ),
      ),
      child: TextButton(
        onPressed: widget.onPressed ??
            () async {
              await Navigator.pushNamed(context, "/product",
                  arguments: {'productData': widget.product});
            },
        onLongPress: widget.onLongPress,
        child: SizedBox(
          height: 125,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (thumbnail != null)
                SizedBox(
                  height: 120,
                  child: thumbnail,
                ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      displayHeader(),
                      displayBody(),
                      // displayFooter()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
