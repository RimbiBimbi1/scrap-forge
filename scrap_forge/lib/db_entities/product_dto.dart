import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:scrap_forge/db_entities/photo.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';

class ProductDTO {
  String name;
  String description;
  List<Uint8List> photos;

  bool isMaterial;
  String category;

  List<int> madeFromIds;
  List<int> usedInIds;

  int addedTimestamp;
  int finishedTimestamp;

  String length;
  String width;
  String height;
  String projectionArea;

  String number;

  ProductDTO({
    this.name = "",
    this.description = "",
    required this.photos,
    this.isMaterial = false,
    this.category = "",
    required this.madeFromIds,
    required this.usedInIds,
    this.addedTimestamp = -1,
    this.finishedTimestamp = -1,
    this.length = "0",
    this.width = "0",
    this.height = "0",
    this.number = "1",
    this.projectionArea = "0",
  });

  static Future<List<Uint8List>> getProductPhotos(Product p) async {
    List<Photo> photoEntities = await IsarService().getPhotosOfThe(p);
    return photoEntities.map((p) => base64Decode(p.imgData ??= "")).toList();
  }

  static Future<ProductDTO> fromProduct(Product p) async {
    List<Uint8List> photos = await getProductPhotos(p);

    return ProductDTO(
      name: p.name ??= "",
      description: p.description ??= "",
      photos: photos,
      isMaterial: p.isMaterial ??= false,
      category: p.category ??= "",
      madeFromIds: List.empty(),
      usedInIds: List.empty(),
      addedTimestamp: p.addedTimestamp ??= -1,
      finishedTimestamp: p.finishedTimestamp ??= -1,
      length: p.length.toString(),
      width: p.width.toString(),
      height: p.height.toString(),
      number: p.number.toString(),
      projectionArea: p.projectionArea.toString(),
    );
  }

  static ProductDTO copy(ProductDTO original) {
    return ProductDTO(
      name: original.name,
      description: original.description,
      photos: original.photos,
      isMaterial: original.isMaterial,
      category: original.category,
      madeFromIds: original.madeFromIds,
      usedInIds: original.usedInIds,
      addedTimestamp: original.addedTimestamp,
      finishedTimestamp: original.finishedTimestamp,
      length: original.length,
      width: original.width,
      height: original.height,
      number: original.number,
      projectionArea: original.projectionArea,
    );
  }

  ProductDTO getCopy() {
    return copy(this);
  }

  Product toProduct() {
    return Product()
      ..name = name
      ..description = description
      ..photos
          .addAll(photos.map((bytes) => Photo()..imgData = base64Encode(bytes)))
      ..category = category
      ..isMaterial = isMaterial
      ..addedTimestamp = addedTimestamp
      ..finishedTimestamp = finishedTimestamp
      ..length = int.parse(length)
      ..width = int.parse(width)
      ..height = int.parse(height)
      ..projectionArea = int.parse(projectionArea)
      ..number = int.parse(number);
  }
}
