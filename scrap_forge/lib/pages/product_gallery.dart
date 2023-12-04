import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/db_entities/product_dto.dart';
import 'package:scrap_forge/utils/fetch_products.dart';
import 'package:scrap_forge/widgets/product_strip.dart';
import 'package:scrap_forge/widgets/recent_strip.dart';

class ProductGallery extends StatefulWidget {
  final BuildContext context;
  const ProductGallery({super.key, required this.context});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  List<Product> products = List.empty();
  bool asMaterials = false;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    const getProducts = fetchProducts;

    final arguments = (ModalRoute.of(widget.context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    ProductFilter filter = arguments["productFilter"];

    // if (filter != null) {
    List<Product> result = await getProducts(filter);

    setState(() {
      products = result;
      asMaterials = filter.materialsOnly;
    });
    // }
  }

  List<Widget> displayProducts() {
    return products
        .map((p) => ProductStrip(product: p, asMaterial: asMaterials))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Produkty"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: [...displayProducts()],
          ),
        ),
      ),
    );
  }
}
