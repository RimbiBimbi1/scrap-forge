import 'dart:ffi';

import 'package:isar/isar.dart';

part 'Product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? name;
  String? description;
  List<String>? imagePaths;
  String? category;
  int? addedTimestamp;
  int? finishedTimestamp;
  bool? isMaterial;
}
