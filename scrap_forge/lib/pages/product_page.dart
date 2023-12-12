import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/utils/date_formatter.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';

class ProductPage extends StatefulWidget {
  BuildContext context;
  ProductPage({super.key, required this.context});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? product;

  @override
  void initState() {
    super.initState();
    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    Product? product = arguments['productData'];
    if (product != null) {
      setState(() {
        this.product = product;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (product != null) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text("Strona produktu"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/editProduct",
                      arguments: {"productData": product});
                },
                icon: const Icon(Icons.settings))
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product!.addedTimestamp != null)
                      Flexible(
                        child: Text(
                          "Data dodania: ${DateFormatter.fromTimestamp(product!.addedTimestamp ??= 0)}",
                          textScaleFactor: 0.75,
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                        ),
                      ),
                    if (product!.finishedTimestamp != null)
                      Flexible(
                        child: Text(
                          "Data ukończenia: ${DateFormatter.fromTimestamp(product!.finishedTimestamp ??= 0)}",
                          textScaleFactor: 0.75,
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        product!.name ??= "",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ],
                ),
                if (product != null && product!.photos.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: ListView(
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...product!.photos.map(
                          (photo) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 160,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                image: DecorationImage(
                                    image: MemoryImage(
                                        base64Decode(photo.imgData ??= "")),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (product?.description != null && product?.description != "")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Opis:",
                        textScaleFactor: 1.25,
                      ),
                      Text(StringMultiliner.multiline(product?.description)
                          .toString()),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return Loading();
  }
}
