import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';

Future<List<Product>> fetchProducts(ProductFilter filter) async {
  final dbService = IsarService();

  List<Product> products = await dbService.getProducts(filter);

  return products;
}

class ProductFilter {
  String nameHas;
  bool showProjects;
  bool showFinished;
  bool showInProgress;
  bool showPlanned;

  bool showMaterials;
  int? minConsumed;
  int? minAvailable;
  int? minNeeded;

  int? maxConsumed;
  int? maxAvailable;
  int? maxNeeded;

  ProductFilter({
    this.nameHas = '',
    this.showProjects = false,
    this.showFinished = false,
    this.showInProgress = false,
    this.showPlanned = false,
    this.showMaterials = false,
    this.minConsumed,
    this.minAvailable,
    this.minNeeded,
    this.maxConsumed,
    this.maxAvailable,
    this.maxNeeded,
  });

  static ProductFilter projects() {
    return ProductFilter(showProjects: true);
  }

  static ProductFilter finishedProducts() {
    return ProductFilter(
      showProjects: true,
      showFinished: true,
    );
  }

  static ProductFilter inProgressProducts() {
    return ProductFilter(
      showProjects: true,
      showInProgress: true,
    );
  }

  static ProductFilter plannedProducts() {
    return ProductFilter(
      showProjects: true,
      showPlanned: true,
    );
  }

  static ProductFilter materials() {
    return ProductFilter(showMaterials: true);
  }

  static ProductFilter consumedMaterials() {
    return ProductFilter(
      showMaterials: true,
      minConsumed: 1,
    );
  }

  static ProductFilter availableMaterials() {
    return ProductFilter(
      showMaterials: true,
      minAvailable: 1,
    );
  }

  static ProductFilter neededMaterials() {
    return ProductFilter(
      showMaterials: true,
      minNeeded: 1,
    );
  }
}
