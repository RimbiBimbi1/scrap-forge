import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'appSettings.g.dart';

@collection
class AppSettings {
  Id id = 1;

  bool darkMode = false;

  @Enumerated(EnumType.ordinal)
  MeasurementToolQuality framingQuality = MeasurementToolQuality.medium;

  @Enumerated(EnumType.ordinal)
  MeasurementToolQuality boundingQuality = MeasurementToolQuality.medium;
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
