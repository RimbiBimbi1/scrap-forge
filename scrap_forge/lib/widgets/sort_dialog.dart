import 'package:flutter/material.dart';

class SortDialog extends StatefulWidget {
  final String sortBy;
  final void Function(String value) onClose;
  const SortDialog({
    super.key,
    required this.sortBy,
    required this.onClose,
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
      title: const Text("Sortowanie:"),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Daty ostatniej modyfikacji"),
            leading: Radio(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).colorScheme.primary),
              value: 'lastModifiedTimestamp',
              groupValue: sortBy,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: const Text("Daty rozpoczęcia"),
            leading: Radio(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).colorScheme.primary),
              value: 'startedTimestamp',
              groupValue: sortBy,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: const Text("Daty ukończenia"),
            leading: Radio(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).colorScheme.primary),
              value: 'finishedTimestamp',
              groupValue: sortBy,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
