import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/utils/date_formatter.dart';
import 'package:scrap_forge/utils/dimension_formatter.dart';
import 'package:scrap_forge/utils/string_multiliner.dart';
import 'package:scrap_forge/widgets/recent_strip.dart';

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
          title: const Text("Strona produktu"),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    product!.name ??= "Nienazwany produkt",
                    textScaleFactor: 1.4,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Zdjęcia:",
                    textScaleFactor: 1.1,
                  ),
                ),
                (product!.photos.isNotEmpty)
                    ? SizedBox(
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    image: DecorationImage(
                                        image: MemoryImage(base64Decode(photo)),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 60),
                          child: const Text(
                            "Do tego produktu nie dodano jeszcze żadnych zdjęć",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                if (product?.description != null && product?.description != "")
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Opis:",
                          textScaleFactor: 1.1,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            StringMultiliner.multiline(product?.description)
                                .toString(),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (product!.count != null)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('Wykonana ilość: ${product!.count}')),
                if (product!.madeFrom.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Materiały wykorzystane do produkcji: "),
                        ...product!.madeFrom.map(
                            (material) => ProductStripSmall(product: material))
                      ],
                    ),
                  ),
                if (product!.isMaterial())
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Użyte: ${product!.consumed ??= 0}"),
                            Text("Na stanie: ${product!.available ??= 0}"),
                            Text("Potrzebne: ${product!.needed ??= 0}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (product!.usedIn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                            "Wykorzystany jako materiał przy produkcji: "),
                        ...product!.usedIn
                            .map((p) => ProductStripSmall(product: p))
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return const Loading();
  }
}
