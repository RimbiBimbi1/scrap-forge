import 'package:isar/isar.dart';
import 'package:scrap_forge/db_entities/product.dart';

part 'photo.g.dart';

@collection
class Photo {
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment
  String? name;
  String? path;

  @Backlink(to: "photos")
  final product = IsarLink<Product>();
}
