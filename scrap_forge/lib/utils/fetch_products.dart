import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';

Future<List<Product>> fetchProducts(ProductFilter filter) async {
  final dbService = IsarService();

  List<Product> products = await dbService.getProducts(filter);

  return products;
}

class ProductFilter {
  bool projectsOnly;
  bool finishedOnly;
  bool inProgressOnly;
  bool plannedOnly;

  bool materialsOnly;
  int consumedOnly;
  int availableOnly;
  int neededOnly;

  ProductFilter({
    this.projectsOnly = false,
    this.finishedOnly = false,
    this.inProgressOnly = false,
    this.plannedOnly = false,
    this.materialsOnly = false,
    this.consumedOnly = -1,
    this.availableOnly = -1,
    this.neededOnly = -1,
  });

  static ProductFilter projects() {
    return ProductFilter(projectsOnly: true);
  }

  static ProductFilter finishedProducts() {
    return ProductFilter(
      projectsOnly: true,
      finishedOnly: true,
    );
  }

  static ProductFilter inProgressProducts() {
    return ProductFilter(
      projectsOnly: true,
      inProgressOnly: true,
    );
  }

  static ProductFilter plannedProducts() {
    return ProductFilter(
      projectsOnly: true,
      plannedOnly: true,
    );
  }

  static ProductFilter materials() {
    return ProductFilter(materialsOnly: true);
  }

  static ProductFilter consumedMaterials() {
    return ProductFilter(
      materialsOnly: true,
      consumedOnly: 0,
    );
  }

  static ProductFilter availableMaterials() {
    return ProductFilter(
      materialsOnly: true,
      availableOnly: 0,
    );
  }

  static ProductFilter neededMaterials() {
    return ProductFilter(
      materialsOnly: true,
      neededOnly: 0,
    );
  }
}
