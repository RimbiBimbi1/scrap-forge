import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'appSettings.g.dart';

@collection
class AppSettings {
  Id id = 1;

  bool darkMode = true;

  @Enumerated(EnumType.ordinal)
  MeasurementToolQuality framingQuality = MeasurementToolQuality.medium;

  @Enumerated(EnumType.ordinal)
  MeasurementToolQuality boundingQuality = MeasurementToolQuality.medium;

  List<SheetFormat> customSheetFormats = List.empty();
  SheetFormat defaultSheetFormat = SheetFormat.a4;
}

enum MeasurementToolQuality {
  veryLow(height: 200, label: "Bardzo niska"),
  low(height: 300, label: 'Niska'),
  medium(height: 400, label: 'Średnia'),
  high(height: 600, label: 'Wysoka'),
  veryHigh(height: 800, label: 'Bardzo wysoka');

  const MeasurementToolQuality({
    required this.height,
    required this.label,
  });

  final short height;
  final String label;
}

@embedded
class SheetFormat {
  final String name;
  final double width;
  final double height;

  const SheetFormat({
    this.name = '',
    this.width = 210,
    this.height = 297,
  });

  static const SheetFormat a5 =
      SheetFormat(name: 'A5', width: 148, height: 210);
  static const SheetFormat a4 =
      SheetFormat(name: 'A4', width: 210, height: 297);
  static const SheetFormat a3 =
      SheetFormat(name: 'A3', width: 297, height: 420);

  String displayNameOrDims() {
    return (name.isNotEmpty) ? name : "$width x $height";
  }
}
