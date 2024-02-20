import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/appSettings.dart';

class MeasurementQualityMenu extends StatefulWidget {
  final MeasurementToolQuality currentQuality;
  final ValueSetter<MeasurementToolQuality> setQuality;
  const MeasurementQualityMenu({
    super.key,
    required this.currentQuality,
    required this.setQuality,
  });

  @override
  State<MeasurementQualityMenu> createState() => _MeasurementQualityMenuState();
}

class _MeasurementQualityMenuState extends State<MeasurementQualityMenu> {
  MeasurementToolQuality selectedQuality = MeasurementToolQuality.medium;

  @override
  void initState() {
    super.initState();
    selectedQuality = widget.currentQuality;
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
          ...MeasurementToolQuality.values
              .map(
                (e) => RadioListTile(
                  value: e,
                  groupValue: selectedQuality,
                  onChanged: (value) => setState(
                    () {
                      selectedQuality = value ?? selectedQuality;
                    },
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(
                    e.label,
                    textScaleFactor: 0.9,
                  ),
                ),
              )
              .toList(),
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
                  widget.setQuality(selectedQuality);
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
