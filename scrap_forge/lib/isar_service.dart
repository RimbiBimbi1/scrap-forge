import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
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

      return await Isar.open([ProductSchema, AppSettingsSchema],
          inspector: true, directory: dir.path);
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> saveSettings(AppSettings appSettings) async {
    final isar = await db;

    isar.writeTxnSync(() {
      isar.appSettings.putSync(appSettings);
    });
  }

  Future<AppSettings?> getAppSettings() async {
    final isar = await db;
    return await isar.appSettings.get(1);
  }

  Future<void> saveProduct(Product product) async {
    final isar = await db;

    isar.writeTxnSync(() {
      isar.products.putSync(product);
    });
  }

  Future<void> saveProducts(List<Product> products) async {
    final isar = await db;

    isar.writeTxnSync(() {
      isar.products.putAllSync(products);
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
        .sortByLastModifiedTimestampDesc()
        .limit(number)
        .findAll();
  }

  Future<List<Product>> getProducts(ProductFilter filter) async {
    final isar = await db;

    QueryBuilder<Product, Product, QAfterFilterCondition> query = isar.products
        .filter()
        .nameContains(filter.nameHas, caseSensitive: false)
        .categoryContains(filter.categoryHas, caseSensitive: false)
        .group((q) => q
            .optional(
              filter.showFinished,
              (q) => q.progressEqualTo(ProjectLifeCycle.finished),
            )
            .or()
            .optional(
              filter.showInProgress,
              (q) => q.progressEqualTo(ProjectLifeCycle.inProgress),
            )
            .or()
            .optional(
              filter.showPlanned,
              (q) => q.progressEqualTo(ProjectLifeCycle.planned),
            ))
        .optional(
          filter.showMaterials,
          (q) => q.group(
            (q) => q.consumedIsNotNull().availableIsNotNull().neededIsNotNull(),
          ),
        )
        .optional(
          !filter.showProjects,
          (q) => q.group(
            (q) => q
                .optional(
                  filter.minConsumed != null,
                  (q) => q
                      .consumedIsNotNull()
                      .consumedGreaterThan(filter.minConsumed! - 1),
                )
                .optional(
                  filter.maxConsumed != null,
                  (q) => q
                      .consumedIsNotNull()
                      .consumedLessThan(filter.maxConsumed! + 1),
                )
                .optional(
                  filter.minAvailable != null,
                  (q) => q
                      .availableIsNotNull()
                      .availableGreaterThan(filter.minAvailable! - 1),
                )
                .optional(
                  filter.maxAvailable != null,
                  (q) => q
                      .availableIsNotNull()
                      .availableLessThan(filter.maxAvailable! + 1),
                )
                .optional(
                  filter.minNeeded != null,
                  (q) => q
                      .neededIsNotNull()
                      .neededGreaterThan(filter.minNeeded! - 1),
                )
                .optional(
                  filter.maxNeeded != null,
                  (q) =>
                      q.neededIsNotNull().neededLessThan(filter.maxNeeded! + 1),
                ),
          ),
        )
        .optional(
          filter.minDimensions != null,
          (q) => q.dimensions(
            (q) => q
                .optional(
                  filter.minDimensions!.length != null,
                  (q) => q.lengthGreaterThan(filter.minDimensions!.length! - 1),
                )
                .optional(
                  filter.minDimensions!.width != null,
                  (q) => q.widthGreaterThan(filter.minDimensions!.width! - 1),
                )
                .optional(
                  filter.minDimensions!.height != null,
                  (q) => q.heightGreaterThan(filter.minDimensions!.height! - 1),
                ),
          ),
        )
        .optional(
          filter.maxDimensions != null,
          (q) => q.dimensions(
            (q) => q
                .optional(
                  filter.maxDimensions!.length != null,
                  (q) => q.lengthLessThan(filter.maxDimensions!.length! + 1),
                )
                .optional(
                  filter.maxDimensions!.width != null,
                  (q) => q.widthLessThan(filter.maxDimensions!.width! + 1),
                )
                .optional(
                  filter.maxDimensions!.height != null,
                  (q) => q.heightLessThan(filter.maxDimensions!.height! + 1),
                ),
          ),
        )
        .optional(
          filter.minStartDate != null,
          (q) => q.startedTimestampGreaterThan(
            filter.minStartDate!.millisecondsSinceEpoch - 1,
          ),
        )
        .optional(
          filter.maxStartDate != null,
          (q) => q.startedTimestampLessThan(
            filter.maxStartDate!.millisecondsSinceEpoch + 1,
          ),
        )
        .optional(
          filter.minFinishDate != null,
          //If the finishedTimestamp is null, then the project is probably still being worked on
          (q) => q.finishedTimestampIsNull().or().finishedTimestampGreaterThan(
                filter.minFinishDate!.millisecondsSinceEpoch - 1,
              ),
        )
        .optional(
          filter.maxFinishDate != null,
          (q) => q.finishedTimestampIsNotNull().finishedTimestampLessThan(
                filter.maxFinishDate!.millisecondsSinceEpoch + 1,
              ),
        );

    // ignore: invalid_use_of_protected_member
    query = QueryBuilder.apply(
      query,
      (query) => query
          .addFilterCondition(
              FilterCondition.isNotNull(property: filter.sortBy))
          .addSortBy(filter.sortBy, filter.sortDesc ? Sort.asc : Sort.desc),
    );

    return query.findAllSync();
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
