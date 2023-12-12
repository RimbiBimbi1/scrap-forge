import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/widgets/product_strip.dart';

class ProductGallery extends StatefulWidget {
  final BuildContext context;
  const ProductGallery({super.key, required this.context});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  List<Product> products = List.empty();
  bool asMaterials = false;
  bool selectionMode = false;
  List<bool> selected = List.empty();
  ValueSetter? confirmSelection;

  @override
  void initState() {
    super.initState();
    getArguments();
  }

  Future<void> getArguments() async {
    const getDbProducts = fetchProducts;

    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    bool? selectionMode = arguments["select"];
    ProductFilter filter = arguments["productFilter"];
    ValueSetter? confirmSelection = arguments["confirmSelection"];

    // if (filter != null) {
    List<Product> result = await getDbProducts(filter);

    setState(() {
      this.products = result;
      this.asMaterials = filter.materialsOnly;
      this.selectionMode = selectionMode ?? false;
      this.selected = List.filled(result.length, false);
      this.confirmSelection = confirmSelection;
    });
    // }
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
                        shape: RoundedRectangleBorder(
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
                  duration: Duration(milliseconds: 200))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      persistentFooterButtons: selectionMode
          ? [
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  setState(() {
                    selectionMode = false;
                    selected = List.filled(selected.length, false);
                  });
                },
                child: Icon(Icons.cancel_outlined),
              ),
              FloatingActionButton(
                heroTag: null,
                onPressed: (confirmSelection != null)
                    ? () {
                        confirmSelection!(getSelected());
                      }
                    : () {},
                child: Icon(Icons.check),
              )
            ]
          : [],
      appBar: AppBar(
        title: Text("Produkty"),
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
          padding: EdgeInsets.all(10),
          child: ListView(
            shrinkWrap: true,
            children: [...displayProducts()],
          ),
        ),
      ),
    );
  }
}
