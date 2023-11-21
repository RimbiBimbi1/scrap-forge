import 'dart:convert';
import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrap_forge/db_entities/photo.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/db_entities/product_dto.dart';

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
    // List<Photo> imageIDs = List.empty(growable: true);
    // for (final bytes in product.photos) {
    //   imageIDs.add((await savePhoto(bytes)));
    // }

    // isar.photos.putAllSync(images);

    isar.writeTxnSync(() async => {await isar.products.put(product)});

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

  Stream<List<Product>> listenToProducts() async* {
    final isar = await db;
    yield* isar.products.where().watch(fireImmediately: true);
  }

  Future<Product?> getProductOnThe(Photo photo) async {
    final isar = await db;
    return await isar.products
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
