import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;

  String? name;
  String? description;
  int? count;

  @Enumerated(EnumType.name)
  ProjectLifeCycle? progress;

  List<String> photos = [];

  String? category;

  final madeFrom = IsarLinks<Product>();
  // List<int> madeFromQuantities = [];

  @Backlink(to: "madeFrom")
  final usedIn = IsarLinks<Product>();
  // List<int> usedInQuantities = [];

  Dimensions? dimensions;

  int? lastModifiedTimestamp;
  int? startedTimestamp;
  int? finishedTimestamp;

  int? consumed;
  int? available;
  int? needed;

  bool isMaterial() {
    return (consumed != null || available != null || needed != null);
  }

  bool isProduct() {
    return (progress != null);
  }
}

@embedded
class Dimensions {
  double? length;
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? lengthDisplayUnit;

  double? width;
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? widthDisplayUnit;

  double? height;
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? heightDisplayUnit;

  double? projectionArea;
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? areaDisplayUnit;

  Dimensions({
    this.length,
    this.lengthDisplayUnit,
    this.width,
    this.widthDisplayUnit,
    this.height,
    this.heightDisplayUnit,
    this.projectionArea,
    this.areaDisplayUnit,
  });
}

enum SizeUnit {
  millimeter(multiplier: 1, name: "millimeter", abbr: "mm"),
  centimeter(multiplier: 10, name: "centimeter", abbr: "cm"),
  decimeter(multiplier: 100, name: "decimeter", abbr: "dm"),
  meter(multiplier: 1000, name: "meter", abbr: "m");

  const SizeUnit({
    required this.multiplier,
    required this.name,
    required this.abbr,
  });

  final short multiplier;
  final String name;
  final String abbr;

  static SizeUnit fromString(String name) {
    switch (name) {
      case 'millimeter':
      case 'mm':
        return SizeUnit.millimeter;
      case 'centimeter':
      case 'cm':
        return SizeUnit.centimeter;
      case 'decimeter':
      case 'dm':
        return SizeUnit.decimeter;
      case 'meter':
      case 'm':
        return SizeUnit.meter;
      default:
        return SizeUnit.millimeter;
    }
  }
}

enum ProjectLifeCycle {
  finished(name: 'finished'),
  inProgress(name: 'inProgress'),
  planned(name: 'planned');

  const ProjectLifeCycle({required this.name});

  final String name;

  static ProjectLifeCycle fromString(String name) {
    switch (name) {
      case 'finished':
        return ProjectLifeCycle.finished;
      case 'inProgress':
        return ProjectLifeCycle.inProgress;
      case 'planned':
        return ProjectLifeCycle.planned;
      default:
        return ProjectLifeCycle.inProgress;
    }
  }
}
