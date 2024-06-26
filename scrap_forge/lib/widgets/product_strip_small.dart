import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scrap_forge/db_entities/product.dart';

class ProductStripSmall extends StatefulWidget {
  final Product product;
  final bool replacing;

  const ProductStripSmall({
    super.key,
    required this.product,
    this.replacing = false,
  });

  @override
  State<ProductStripSmall> createState() => _ProductStripSmallState();
}

class _ProductStripSmallState extends State<ProductStripSmall> {
  Widget? thumbnail;

  void getImage() {
    List<int> data;

    if (widget.product.photos.isEmpty) {
      return;
    }

    data = widget.product.photos.first.data;
    Uint8List bytes = Uint8List.fromList(data);
    setState(() {
      thumbnail = Image(image: MemoryImage(bytes));
    });
    return;
  }

  Text displayName() {
    ThemeData theme = Theme.of(context);

    String name = "Twój wspaniały projekt";
    if (widget.product.name != null) {
      name = widget.product.name!;
    }
    return Text(
      name,
      textScaleFactor: 1.2,
      style: TextStyle(color: theme.colorScheme.onSecondary),
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
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: theme.colorScheme.secondary,
      ),
      child: TextButton(
        onPressed: () async {
          if (widget.replacing) {
            await Navigator.pushReplacementNamed(context, "/product",
                arguments: {'productData': widget.product});
          } else {
            await Navigator.pushNamed(context, "/product",
                arguments: {'productData': widget.product});
          }
        },
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: (thumbnail != null)
                  ? thumbnail
                  : SvgPicture.asset(
                      'assets/images/anvil_placeholder.svg',
                      fit: BoxFit.fitWidth,
                    ),
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
