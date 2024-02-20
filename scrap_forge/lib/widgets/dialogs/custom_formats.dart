import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/appSettings.dart';
import 'package:scrap_forge/widgets/dialogs/custom_format_editor.dart';

class CustomFormats extends StatefulWidget {
  final List<SheetFormat> customFormats;
  final ValueSetter<List<SheetFormat>> setFormats;
  const CustomFormats({
    super.key,
    required this.customFormats,
    required this.setFormats,
  });

  @override
  State<CustomFormats> createState() => _CustomFormatsState();
}

class _CustomFormatsState extends State<CustomFormats> {
  List<SheetFormat> formats = List.empty();

  @override
  void initState() {
    super.initState();
    formats = widget.customFormats;
  }

  Future<void> _displayFormatEditor({int editedIndex = -1}) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        bool editingMode = (editedIndex > -1 && editedIndex < formats.length);
        return CustomFormatEditor(
          edited: editingMode ? formats[editedIndex] : null,
          saveFormat: editingMode
              ? (edited) {
                  List<SheetFormat> temp = List.from(formats);
                  temp[editedIndex] = edited;
                  setState(() {
                    formats = temp;
                  });
                  widget.setFormats(temp);
                }
              : (added) {
                  List<SheetFormat> temp = [...formats, added];
                  setState(() {
                    formats = temp;
                  });
                  widget.setFormats(temp);
                },
        );
      },
    );
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
                  .asMap()
                  .map(
                    (i, format) => MapEntry(
                      i,
                      ListTile(
                        title: Text(format.name),
                        subtitle: Text(
                          "${format.height}mm x ${format.width}mm",
                          textScaleFactor: 0.9,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                List<SheetFormat> temp = formats
                                    .where((element) => element != format)
                                    .toList();
                                setState(() {
                                  formats = temp;
                                  widget.setFormats(temp);
                                });
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _displayFormatEditor(editedIndex: i),
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
