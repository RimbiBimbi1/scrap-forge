import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';

class DefaultFormatMenu extends StatefulWidget {
  final Map<String, SheetFormat> formatOptions;
  final SheetFormat currentFormat;
  final ValueSetter<SheetFormat> setFormat;
  const DefaultFormatMenu({
    super.key,
    required this.formatOptions,
    required this.currentFormat,
    required this.setFormat,
  });

  @override
  State<DefaultFormatMenu> createState() => _DefaultFormatMenuState();
}

class _DefaultFormatMenuState extends State<DefaultFormatMenu> {
  SheetFormat selectedFormat = SheetFormat.a4;

  @override
  void initState() {
    super.initState();
    selectedFormat = widget.currentFormat;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Wybierz domyślny format podkładu:"),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Scrollbar(
        thumbVisibility: true,
        child: ListView(shrinkWrap: true, children: [
          ...widget.formatOptions
              .map(
                (key, value) => MapEntry(
                  key,
                  RadioListTile(
                    value: value.name,
                    groupValue: selectedFormat.name,
                    onChanged: (value) => setState(() {
                      selectedFormat =
                          widget.formatOptions[value] ?? selectedFormat;
                    }),
                    activeColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      value.name,
                      textScaleFactor: 0.9,
                    ),
                    subtitle: Text(
                      "${value.width.toInt()}mm x ${value.height.toInt()}mm",
                      textScaleFactor: 0.9,
                    ),
                  ),
                ),
              )
              .values,
        ]),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Anuluj"),
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: () {
                  widget.setFormat(selectedFormat);
                  Navigator.of(context).pop();
                },
                child: const Text("Zatwierdź"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
