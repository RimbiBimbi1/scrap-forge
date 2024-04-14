import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/pages/gallery_filter_menu.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/utils/product_list_comparator.dart';
import 'package:scrap_forge/widgets/product_strip.dart';
import 'package:scrap_forge/widgets/dialogs/sort_menu.dart';

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
  List<GlobalKey> productKeys1 = List.empty();
  List<GlobalKey> productKeys2 = List.empty();
  bool selectionMode = false;
  List<bool> selected = List.empty();
  ValueSetter<List<Product>>? confirmSelection;
  ProductFilter baseFilter = ProductFilter();

  TextEditingController moveFromController = TextEditingController();
  TextEditingController moveToController = TextEditingController();
  // ProductFilter? customFilter;

  @override
  void initState() {
    super.initState();
    getArguments();

    db.listenToProducts().listen(
      (event) async {
        List<Product> result = await getProducts((() => baseFilter)());

        if (mounted &&
            !ProductListComparator.compareByLastModifiedTimestamps(
                products, result)) {
          setState(() {
            this.products = result;
            this.productKeys1 =
                List.generate(result.length, (index) => GlobalKey());
            this.productKeys2 =
                List.generate(result.length, (index) => GlobalKey());
            this.selected = List.filled(result.length, false);
          });
        }
      },
    );
  }

  Future<void> getArguments() async {
    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    bool? selectionMode = arguments["select"];
    ProductFilter baseFilter = arguments["productFilter"];
    ValueSetter<List<Product>>? confirmSelection =
        arguments["confirmSelection"];

    // if (filter != null) {
    List<Product> result = await getProducts(baseFilter);

    setState(() {
      this.products = result;
      this.productKeys1 = List.generate(result.length, (index) => GlobalKey());
      this.productKeys2 = List.generate(result.length, (index) => GlobalKey());
      this.selected = List.filled(result.length, false);
      this.baseFilter = baseFilter;
      this.selectionMode = selectionMode ?? false;
      this.confirmSelection = confirmSelection;
    });
  }

  Future<List<Product>> getProducts(filter) async {
    const getDbProducts = fetchProducts;
    return await getDbProducts(filter);
  }

  Future<void> onFilterUpdate(filter) async {
    List<Product> products = await getProducts(filter);
    setState(() {
      this.products = products;
      this.productKeys1 =
          List.generate(products.length, (index) => GlobalKey());
      this.productKeys2 =
          List.generate(products.length, (index) => GlobalKey());
      this.baseFilter = filter;
      this.selected = List.filled(products.length, false);
    });
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
    return products
        .asMap()
        .map(
          (index, p) => MapEntry(
              index,
              AnimatedCrossFade(
                  key: GlobalKey(),
                  firstChild: Row(
                    children: [
                      Flexible(
                        child: ProductStrip(
                            key: productKeys1[index],
                            product: p,
                            // asMaterial: projectsOnly,
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
                    key: productKeys2[index],
                    // asMaterial: projectsOnly,
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
          child: SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Przenieś wybrane projekty do:",
                    textScaleFactor: 1.4,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      {
                        'label': "Ukończone",
                        'move': (Product p) =>
                            p..progress = ProjectLifeCycle.finished
                      },
                      {
                        'label': "W trakcie realizacji",
                        'move': (Product p) =>
                            p..progress = ProjectLifeCycle.inProgress
                      },
                      {
                        'label': "Planowanie",
                        'move': (Product p) =>
                            p..progress = ProjectLifeCycle.planned
                      },
                    ]
                        .map(
                          (folder) => OutlinedButton(
                            onPressed: () {
                              List<Product> moved = products
                                  .asMap()
                                  .entries
                                  .where((p) => selected[p.key])
                                  .map((e) => (folder['move'] as Product
                                      Function(Product p))(e.value))
                                  .toList();

                              db.saveProducts(moved);

                              Navigator.of(context).pop();
                            },
                            child: Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                (folder['label'] ?? "").toString(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Anuluj'))
                ],
              ),
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

  Future<void> _displaySortDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return SortMenu(
          initSortBy: baseFilter.sortBy,
          initSortDesc: baseFilter.sortDesc,
          setSort: (sortBy, sortDesc) {
            setState(() {
              onFilterUpdate(
                baseFilter
                  ..sortBy = sortBy
                  ..sortDesc = sortDesc,
              );
            });
          },
          sortMaterials: baseFilter.showMaterials,
          sortProjects: baseFilter.showProjects,
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

    ThemeData theme = Theme.of(context);

    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
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
                      (baseFilter.showProjects)
                          ? TextButton(
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
                            )
                          : SizedBox.shrink(),
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
            onPressed: _displaySortDialog,
            icon: const Icon(Icons.sort_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryFilterMenu(
                    setFilter: (ProductFilter filter) {
                      onFilterUpdate(filter);
                      Navigator.of(context).pop();
                    },
                    filter: baseFilter,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            shrinkWrap: true,
            children: displayProducts(),
          ),
        ),
      ),
    );
  }
}
