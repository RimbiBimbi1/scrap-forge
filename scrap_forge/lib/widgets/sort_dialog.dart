import 'package:flutter/material.dart';

class SortDialog extends StatefulWidget {
  final String sortBy;
  final void Function(String value) onClose;
  final bool sortProjects;
  final bool sortMaterials;
  const SortDialog({
    super.key,
    required this.sortBy,
    required this.onClose,
    required this.sortProjects,
    required this.sortMaterials,
  });

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  String sortBy = 'lastModifiedTimestamp';

  @override
  void initState() {
    super.initState();
    this.sortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sortuj według:"),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          children: [
            {'label': 'Szerokości', 'value': 'widthmm'},
            {'label': 'Długości', 'value': 'lengthmm'},
            {'label': 'Wysokości', 'value': 'heightmm'},
            {'label': 'Powierzchni rzutu', 'value': 'projectionAreamm'},
            {'label': 'Maksymalnej powierzchni', 'value': 'maxArea'},
            {'label': 'Objętości', 'value': 'volume'},

            {
              'label': 'Daty ostatniej modyfikacji',
              'value': 'lastModifiedTimestamp'
            },
            ...widget.sortProjects
                ? [
                    {'label': 'Ilości wykonanych sztuk', 'value': 'count'},
                    {'label': 'Daty rozpoczęcia', 'value': 'startedTimestamp'},
                    {'label': 'Daty ukończenia', 'value': 'finishedTimestamp'},
                  ]
                : [],
            ...widget.sortMaterials
                ? [
                    {
                      'label': 'Ilości wykorzystanych sztuk',
                      'value': 'consumed'
                    },
                    {'label': 'Ilości dostępnych sztuk', 'value': 'available'},
                    {'label': 'Ilości brakujących sztuk', 'value': 'needed'},
                  ]
                : [],

            // {'label': '', 'value': ''},
          ]
              .map(
                (e) => ListTile(
                  onTap: () => setState(() {
                    sortBy = e['value'] as String;
                  }),
                  title: Text(e['label'] as String),
                  leading: Radio(
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => Theme.of(context).colorScheme.primary),
                    value: e['value'] as String,
                    groupValue: sortBy,
                    onChanged: (val) => {},
                  ),
                  minLeadingWidth: 0,
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                ),
              )
              .toList(),
        ),
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
                  widget.onClose(sortBy);
                  Navigator.of(context).pop();
                },
                child: const Text("Sortuj"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
