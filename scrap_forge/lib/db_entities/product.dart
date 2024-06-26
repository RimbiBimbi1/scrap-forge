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

  List<Photo> photos = [];

  String? category;

  final madeFrom = IsarLinks<Product>();

  @Backlink(to: "madeFrom")
  final usedIn = IsarLinks<Product>();

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

  double? get lengthmm => dimensions?.length;
  double? get widthmm => dimensions?.width;
  double? get heightmm => dimensions?.height;

  double? get projectionAreamm => dimensions?.projectionArea ?? 0;
  double? get maxArea {
    List<double> nonNullDims = [
      dimensions?.width,
      dimensions?.length,
      dimensions?.height
    ].whereType<double>().toList();

    if (nonNullDims.length < 2) {
      return null;
    }

    nonNullDims.sort((a, b) => (a - b).toInt());

    return nonNullDims[0] * nonNullDims[1];
  }

  double? get volume {
    List<double> nonNullDims = [
      dimensions?.width,
      dimensions?.length,
      dimensions?.height
    ].whereType<double>().toList();

    if (nonNullDims.length == 3) {
      return (dimensions!.width! / 100) *
          (dimensions!.length! / 100) *
          (dimensions!.height! / 100);
    }

    return null;
  }
}

@embedded
class Photo {
  List<int> data = [];
}

@embedded
class Dimensions {
  double? length; //długość w mm
  //adnotacja dotycząca sposobu przechowywania w bazie danych
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? lengthDisplayUnit; //jednostka długości

  double? width; //szerokość w mm
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? widthDisplayUnit; //j.w.

  double? height; //wysokosc w mm
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? heightDisplayUnit; //j.w.

  double? projectionArea; //przybliżone pole powierzchni w mm2
  @Enumerated(EnumType.value, 'multiplier')
  SizeUnit? areaDisplayUnit; //j.w.

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
