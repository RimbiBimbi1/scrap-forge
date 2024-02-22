import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/widgets/dialogs/custom_format_editor.dart';

class CustomFormats extends StatefulWidget {
  final Map<String, SheetFormat> customFormats;
  final Map<String, SheetFormat> baseFormats;
  final ValueSetter<Map<String, SheetFormat>> setFormats;
  const CustomFormats({
    super.key,
    required this.baseFormats,
    required this.customFormats,
    required this.setFormats,
  });

  @override
  State<CustomFormats> createState() => _CustomFormatsState();
}

class _CustomFormatsState extends State<CustomFormats> {
  // List<SheetFormat> formats = List.empty();
  Map<String, SheetFormat> formats = {};

  @override
  void initState() {
    super.initState();
    // formats = widget.customFormats;
    formats = widget.customFormats;
  }

  // bool compareFormats(SheetFormat f1, SheetFormat f2) {
  //   return f1.name == f2.name || SheetFormat.compareDimensions(f1, f2) == 0;
  // }

  // bool formatExists(SheetFormat newformat) {
  //   return formats.any((format) => compareFormats(format, newformat));
  // }

  Future<void> _displayFormatEditor({String? toBeEdited}) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return CustomFormatEditor(
            formats: Map.fromEntries([
              ...widget.baseFormats.entries,
              ...widget.customFormats.entries
            ]),
            edited: formats[toBeEdited],
            saveFormat: (edited) {
              Map<String, SheetFormat> temp = Map.from(formats);
              temp.remove(toBeEdited);
              temp.addEntries([MapEntry(edited.name, edited)]);
              setState(() {
                formats = temp;
              });
              widget.setFormats(temp);
            }

            // validateFormat: (),
            );
      },
    );
  }

  void removeFormat(format) {
    Map<String, SheetFormat> temp = Map.from(formats);
    temp.removeWhere((key, value) => format == value);
    setState(() {
      formats = temp;
      widget.setFormats(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Własne formaty:"),
      titlePadding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
      content: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          shrinkWrap: true,
          children: formats.isNotEmpty
              ? formats
                  .map(
                    (name, format) => MapEntry(
                      name,
                      ListTile(
                        title: Text(format.name),
                        subtitle: Text(
                          "${format.width.toInt()}mm x ${format.height.toInt()}mm",
                          textScaleFactor: 0.9,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => removeFormat(format),
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _displayFormatEditor(toBeEdited: name),
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .values
                  .toList()
              : [
                  const Text(
                    "Nie dodałeś jeszcze żadnych własnych formatów",
                    textAlign: TextAlign.center,
                    textScaleFactor: 0.9,
                  )
                ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: OutlinedButton(
                onPressed: _displayFormatEditor,
                child: const Text("Dodaj format"),
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: () {
                  // widget.setFormat(selectedFormat);
                  Navigator.of(context).pop();
                },
                child: const Text("Wyjdź"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
