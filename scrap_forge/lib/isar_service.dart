import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/photo.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/fetch_products.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  // Future<Photo> savePhoto(Uint8List bytes) async {
  //   final isar = await db;
  //   final photo = Photo()..imgData = base64Encode(bytes);

  //   return await isar
  //       .writeTxn(() async => photo..id = await isar.photos.put(photo));
  // }

  Future<void> saveProduct(Product product) async {
    final isar = await db;

    // Product product = dto.toProduct();
    // List<Photo> imageIDs = List.empty(growable: true);
    // for (final bytes in product.photos) {
    //   imageIDs.add((await savePhoto(bytes)));
    // }

    // isar.photos.putAllSync(images);

    // await isar.writeTxn(() async => {
    //       await isar.products.put(product),
    //       // await isar.photos.putAll(dto.photos),
    //       for (final photo in product.photos) {await isar.photos.put(photo)},
    //       await product.photos.save()
    //     });

    isar.writeTxnSync(() {
      isar.products.deleteSync(product.id);
      isar.products.putSync(product);
    });

    //To do
  }

  // Future<void> saveProduct(Product newProduct) async {
  //   final isar = await db;
  //   isar.writeTxnSync<int>(() => isar.products.putSync(newProduct));
  // }

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

  Future<Product?> getProductOnThe(Photo photo) async {
    final isar = await db;
    return isar.products
        .filter()
        .photos((q) => q.idEqualTo(photo.id))
        .findFirstSync();
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

  // Future<void> clearProductLinked(Product product) async {
  //   final isar = await db;
  //   isar.writeTxnSync(() {
  //     isar.photos
  //         .deleteAllSync(product.photos.map((photo) => photo.id).toList());
  //     isar.products.get(product.id)
  //     product.usedIn.clear();
  //   });
  // }

  Future<void> savePhoto(Photo newPhoto) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.photos.putSync(newPhoto));
  }

  Future<List<Photo>> getAllPhotos() async {
    final isar = await db;
    return await isar.photos.where().findAll();
  }

  Future<List<Photo>> getPhotosOfThe(Product product) async {
    final isar = await db;
    return await isar.photos
        .filter()
        .product((p) => p.idEqualTo(product.id))
        .findAll();
  }

  Stream<List<Photo>> listenToPhotos() async* {
    final isar = await db;
    yield* isar.photos.where().watch(fireImmediately: true);
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      return await Isar.open([PhotoSchema, ProductSchema],
          inspector: true, directory: dir.path);
    }

    return Future.value(Isar.getInstance());
  }
}
