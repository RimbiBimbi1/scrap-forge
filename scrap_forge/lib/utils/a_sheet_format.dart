enum ASheetFormat {
  a5(name: 'A5', width: 148, height: 210),
  a4(name: 'A4', width: 210, height: 297),
  a3(name: 'A3', width: 297, height: 420);

  const ASheetFormat({
    required this.name,
    required this.width,
    required this.height,
  });

  final String name;
  final double width;
  final double height;
}
