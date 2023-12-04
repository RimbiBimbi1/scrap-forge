import 'dart:convert';
import 'dart:typed_data';

import 'package:scrap_forge/db_entities/photo.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/isar_service.dart';

class ProductDTO {
  String name;
  String description;
  List<Uint8List> photos;

  ProjectLifeCycle? progress;

  String category;

  List<int> madeFromIds;
  List<int> usedInIds;

  int addedTimestamp;
  int finishedTimestamp;

  String length;
  String width;
  String height;
  String projectionArea;

  String consumed;
  String available;
  String needed;

  ProductDTO({
    this.name = "",
    this.description = "",
    required this.photos,
    this.progress = null,
    this.category = "",
    required this.madeFromIds,
    required this.usedInIds,
    this.addedTimestamp = -1,
    this.finishedTimestamp = -1,
    this.length = "",
    this.width = "",
    this.height = "",
    this.consumed = "",
    this.available = "",
    this.needed = "",
    this.projectionArea = "",
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
      progress: null,
      category: p.category ??= "",
      madeFromIds: List.empty(),
      usedInIds: List.empty(),
      addedTimestamp: p.addedTimestamp ??= -1,
      finishedTimestamp: p.finishedTimestamp ??= -1,
      length: p.length != null ? p.length.toString() : "",
      width: p.width != null ? p.width.toString() : "",
      height: p.height != null ? p.height.toString() : "",
      consumed: p.consumed != null ? p.consumed.toString() : "",
      available: p.available != null ? p.available.toString() : "",
      needed: p.needed != null ? p.needed.toString() : "",
      projectionArea:
          p.projectionArea != null ? p.projectionArea.toString() : "",
    );
  }

  static ProductDTO copy(ProductDTO original) {
    return ProductDTO(
      name: original.name,
      description: original.description,
      photos: original.photos,
      progress: original.progress,
      category: original.category,
      madeFromIds: original.madeFromIds,
      usedInIds: original.usedInIds,
      addedTimestamp: original.addedTimestamp,
      finishedTimestamp: original.finishedTimestamp,
      length: original.length,
      width: original.width,
      height: original.height,
      consumed: original.consumed,
      available: original.available,
      needed: original.needed,
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
      ..progress = progress
      ..addedTimestamp = addedTimestamp
      ..finishedTimestamp = finishedTimestamp
      ..length = length.isNotEmpty ? int.parse(length) : null
      ..width = width.isNotEmpty ? int.parse(width) : null
      ..height = height.isNotEmpty ? int.parse(height) : null
      ..projectionArea =
          projectionArea.isNotEmpty ? int.parse(projectionArea) : null
      ..consumed = consumed.isNotEmpty ? int.parse(consumed) : null
      ..available = available.isNotEmpty ? int.parse(available) : null
      ..needed = needed.isNotEmpty ? int.parse(needed) : null;
  }
}
