import 'package:flutter/material.dart';
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

  int? consumed;
  int? available;
  int? needed;
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
