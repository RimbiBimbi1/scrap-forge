import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/fetch_products.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open([ProductSchema],
          inspector: true, directory: dir.path);
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> saveProduct(Product product) async {
    final isar = await db;

    isar.writeTxnSync(() {
      isar.products.putSync(product);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    return await isar.products.where().findAll();
  }

  Future<List<Product>> getNewestProducts(int number) async {
    final isar = await db;
    return await isar.products
        .where()
        .sortByAddedTimestamp()
        .limit(number)
        .findAll();
  }

  Future<List<Product>> getProducts(ProductFilter filter) async {
    final isar = await db;

    return isar.products
        .filter()
        .optional(
          filter.projectsOnly,
          (q) => q
              .progressIsNotNull()
              .optional(
                filter.finishedOnly,
                (q) => q.progressMatches(ProjectLifeCycle.finished.name),
              )
              .optional(
                filter.inProgressOnly,
                (q) => q.progressMatches(ProjectLifeCycle.inProgress.name),
              )
              .optional(
                filter.plannedOnly,
                (q) => q.progressMatches(ProjectLifeCycle.planned.name),
              ),
        )
        .optional(
          filter.materialsOnly,
          (q) => q
              .group(
                (q) => q
                    .neededIsNotNull()
                    .or()
                    .availableIsNotNull()
                    .or()
                    .consumedIsNotNull(),
              )
              .optional(
                filter.consumedOnly > -1,
                (q) => q.consumedGreaterThan(filter.consumedOnly),
              )
              .optional(
                filter.availableOnly > -1,
                (q) => q.availableGreaterThan(filter.availableOnly),
              )
              .optional(
                filter.neededOnly > -1,
                (q) => q.neededGreaterThan(filter.neededOnly),
              ),
        )
        .findAllSync();
  }

  Stream<List<Product>> listenToProducts() async* {
    final isar = await db;
    yield* isar.products.where().watch(fireImmediately: true);
  }

  Future<List<Product>> getProductsMadeFrom(Product material) async {
    final isar = await db;
    return await isar.products
        .filter()
        .madeFrom((q) => q.idEqualTo(material.id))
        .findAll();
  }

  Future<List<Product>> getProductsUsedToMake(Product product) async {
    final isar = await db;
    return await isar.products
        .filter()
        .usedIn((q) => q.idEqualTo(product.id))
        .findAll();
  }

  Future<void> deleteProducts(List<Product> products) async {
    final isar = await db;
    isar.writeTxn(() async {
      await isar.products.deleteAll(products.map((p) => p.id).toList());
    });
  }

  Future<void> deleteProduct(Product product) async {
    final isar = await db;
    isar.writeTxnSync(() {
      isar.products.delete(product.id);
    });
  }
}
