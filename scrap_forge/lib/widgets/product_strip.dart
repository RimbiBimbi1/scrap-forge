import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/dimension_formatter.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';

class ProductStrip extends StatefulWidget {
  final Product product;
  final bool asMaterial;
  final VoidCallback? onLongPress;
  final VoidCallback? onPressed;
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

  void getImage() {
    List<int> data;

    if (widget.product.photos.isEmpty) {
      return;
    }

    data = widget.product.photos.first.data;
    Uint8List bytes = Uint8List.fromList(data);
    setState(() {
      thumbnail = Image(
        fit: BoxFit.fill,
        image: MemoryImage(bytes),
      );
    });
    return;
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
    if (!widget.asMaterial) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            StringMultiliner.multiline(widget.product.description).toString(),
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
                const Divider(),
                Text("Wykorzystane: ${widget.product.consumed ?? 0}"),
                Text("Na stanie: ${widget.product.available ?? 0}"),
                Text("Potrzebne: ${widget.product.needed ?? 0}")
              ],
            )),
      );
    }
  }

  Widget displayFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        (widget.product.startedTimestamp != null)
            ? Text(
                "Zaczęto: ${DateTime.fromMillisecondsSinceEpoch(1000 * widget.product.startedTimestamp!).toString().substring(0, 10)}",
                maxLines: 1,
              )
            : Container(),
        (!widget.asMaterial && widget.product.finishedTimestamp != null)
            ? Text(
                "Ukończono: ${DateTime.fromMillisecondsSinceEpoch(1000 * widget.product.finishedTimestamp!).toString().substring(0, 10)}",
                maxLines: 1,
              )
            : Container()
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
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(5),
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
                if (thumbnail != null) SizedBox(height: 120, child: thumbnail),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        displayHeader(),
                        displayBody(),
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
