import 'package:isar/isar.dart';
import 'package:scrap_forge/db_entities/photo.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  String? name;
  String? description;

  @Enumerated(EnumType.name)
  ProjectLifeCycle? progress;

  final photos = IsarLinks<Photo>();

  String? category;

  final madeFrom = IsarLinks<Product>();

  @Backlink(to: "madeFrom")
  final usedIn = IsarLinks<Product>();

  int? addedTimestamp;
  int? finishedTimestamp;

  int? length;
  int? width;
  int? height;
  int? projectionArea;

  int? consumed;
  int? available;
  int? needed;
}

enum ProjectLifeCycle {
  finished(),
  inProgress(),
  planned(),
}
