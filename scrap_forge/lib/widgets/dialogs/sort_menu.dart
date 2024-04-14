import 'package:flutter/material.dart';

class SortMenu extends StatefulWidget {
  final String initSortBy;
  final bool initSortDesc;
  final void Function(String sortBy, bool sortDesc) setSort;
  final bool sortProjects;
  final bool sortMaterials;
  const SortMenu({
    super.key,
    required this.initSortBy,
    required this.initSortDesc,
    required this.setSort,
    required this.sortProjects,
    required this.sortMaterials,
  });

  @override
  State<SortMenu> createState() => _SortMenuState();
}

class _SortMenuState extends State<SortMenu> {
  String sortBy = 'lastModifiedTimestamp';
  bool sortDesc = true;

  @override
  void initState() {
    super.initState();
    this.sortBy = widget.initSortBy;
    this.sortDesc = widget.initSortDesc;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sortuj:"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "malejąco",
                textScaleFactor: 0.8,
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Switch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: sortDesc,
                    onChanged: (value) {
                      setState(() {
                        sortDesc = value;
                      });
                    }),
              ),
              const Text(
                "rosnąco",
                textScaleFactor: 0.8,
              ),
            ],
          ),
          const Text(
            "według:",
            textScaleFactor: 0.8,
          ),
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          shrinkWrap: true,
          children: [
            {'label': 'Długości', 'value': 'lengthmm'},
            {'label': 'Szerokości', 'value': 'widthmm'},
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
          ]
              .map(
                (e) => ListTile(
                  onTap: () => setState(() {
                    sortBy = e['value'] as String;
                  }),
                  title: Text(e['label'] as String),
                  leading: IgnorePointer(
                    child: Radio(
                      fillColor: MaterialStateColor.resolveWith(
                          (states) => Theme.of(context).colorScheme.primary),
                      value: e['value'] as String,
                      groupValue: sortBy,
                      onChanged: (val) => {},
                    ),
                  ),
                  minLeadingWidth: 0,
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
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
                  widget.setSort(sortBy, sortDesc);
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
