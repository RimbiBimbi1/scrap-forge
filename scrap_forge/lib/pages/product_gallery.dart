import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/product_list_comparator.dart';
import 'package:scrap_forge/widgets/product_strip.dart';

enum SelectionOptions { delete() }

class ProductGallery extends StatefulWidget {
  final BuildContext context;
  const ProductGallery({super.key, required this.context});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  IsarService db = IsarService();
  List<Product> products = List.empty();
  bool asMaterials = false;
  bool selectionMode = false;
  List<bool> selected = List.empty();
  ValueSetter? confirmSelection;
  ProductFilter filter = ProductFilter();

  @override
  void initState() {
    super.initState();
    getArguments();
  }

  Future<void> getArguments() async {
    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    bool? selectionMode = arguments["select"];
    ProductFilter filter = arguments["productFilter"];
    ValueSetter? confirmSelection = arguments["confirmSelection"];

    // if (filter != null) {
    List<Product> result = await getProducts(filter);

    setState(() {
      this.products = result;
      this.selected = List.filled(result.length, false);
      this.filter = filter;
      this.asMaterials = filter.materialsOnly;
      this.selectionMode = selectionMode ?? false;
      this.confirmSelection = confirmSelection;
    });
    // }
  }

  Future<List<Product>> getProducts(filter) async {
    const getDbProducts = fetchProducts;
    return await getDbProducts(filter);
  }

  void onTileLongPress(int index) {
    List<bool> copy = List.from(selected);
    copy[index] = true;
    setState(() {
      selected = copy;
      selectionMode = true;
    });
  }

  List<Widget> displayProducts() {
    // return AnimatedCrossFade(firstChild: firstChild, secondChild: secondChild, crossFadeState: crossFadeState, duration: duration)

    return products
        .asMap()
        .map(
          (index, p) => MapEntry(
              index,
              AnimatedCrossFade(
                  firstChild: Row(
                    children: [
                      Flexible(
                        child: ProductStrip(
                            product: p,
                            asMaterial: asMaterials,
                            // onLongPress: () => onTileLongPress(index),
                            onPressed: () =>
                                {updateSelected(index, !selected[index])}),
                      ),
                      Checkbox(
                        value: selected[index],
                        onChanged: ((value) => updateSelected(index, value)),
                        checkColor: Colors.red,
                        activeColor: Colors.red,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(3))),
                      ),
                    ],
                  ),
                  secondChild: ProductStrip(
                    product: p,
                    asMaterial: asMaterials,
                    onLongPress: () => onTileLongPress(index),
                  ),
                  crossFadeState: selectionMode
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200))),
        )
        .values
        .toList();
  }

  void updateSelected(int index, bool? value) {
    List<bool> copy = List.from(selected);
    copy[index] = value ?? !copy[index];
    setState(() {
      selected = copy;
    });
  }

  List<Product> getSelected() {
    List<Product> result = List.empty(growable: true);
    for (final (i, p) in products.indexed) {
      if (selected[i]) result.add(p);
    }
    return result;
  }

  Future<void> _displayMoveDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Przenieś wybrane produkty do:",
                  textScaleFactor: 1.4,
                ),
                ...(asMaterials
                        ? [
                            ProductFilter.finishedProducts(),
                            ProductFilter.inProgressProducts(),
                            ProductFilter.plannedProducts(),
                          ]
                        : [
                            ProductFilter.consumedMaterials(),
                            ProductFilter.availableMaterials(),
                            ProductFilter.neededMaterials(),
                          ])
                    .map((filter) =>
                        //TODO
                        Placeholder())
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _displayDeleteDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Usunąć wybrane produkty?"),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          content: const Text("Usuniętych produktów nie da się przywrócić"),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Anuluj"),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {
                      db.deleteProducts(getSelected());
                      Navigator.of(context).pop();
                    },
                    child: const Text("Usuń"),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    db.listenToProducts().listen((event) async {
      List<Product> result = await getProducts(filter);

      if (mounted &&
          !ProductListComparator.compareByLastModifiedTimestamps(
              products, result)) {
        setState(() {
          this.products = result;
          this.selected = List.filled(result.length, false);
        });
      }
    });
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.grey[900],
      persistentFooterButtons: [
        AnimatedCrossFade(
          crossFadeState: selectionMode
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
          firstChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  selectionMode = false;
                  selected = List.filled(selected.length, false);
                }),
                child: const Column(
                  children: [Icon(Icons.close), Text("Anuluj")],
                ),
              ),
              ...(confirmSelection != null)
                  ? [
                      TextButton(
                        onPressed: () => confirmSelection!(getSelected()),
                        child: const Column(
                          children: [Icon(Icons.check), Text("Zatwierdź")],
                        ),
                      ),
                    ]
                  : [
                      TextButton(
                        onPressed: _displayMoveDialog,
                        child: Column(
                          children: [
                            Transform.rotate(
                              angle: math.pi / 2,
                              child: const Icon(
                                Icons.move_down,
                              ),
                            ),
                            const Text("Przenieś")
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _displayDeleteDialog,
                        child: const Column(
                          children: [
                            Icon(Icons.delete),
                            Text("Usuń"),
                          ],
                        ),
                      ),
                    ]
            ],
          ),
          secondChild: const SizedBox.shrink(),
        )
      ],
      appBar: AppBar(
        title: const Text("Produkty"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            shrinkWrap: true,
            children: [...displayProducts()],
          ),
        ),
      ),
    );
  }
}
