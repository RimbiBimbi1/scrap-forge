import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

class CustomFormatEditor extends StatefulWidget {
  final ValueSetter<SheetFormat> saveFormat;
  final SheetFormat? edited;
  const CustomFormatEditor({
    super.key,
    required this.saveFormat,
    this.edited,
  });

  @override
  State<CustomFormatEditor> createState() => _CustomFormatEditor();
}

class _CustomFormatEditor extends State<CustomFormatEditor> {
  TextEditingController nameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.edited?.name ?? "";
    heightController.text = (widget.edited?.height ?? "").toString();
    widthController.text = (widget.edited?.width ?? "").toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Dodaj format:"),
      titlePadding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      content: ListView(
        // mainAxisSize: MainAxisSize.min,
        shrinkWrap: true,
        children: [
          CustomTextField(
            label: Text("Nazwa"),
            controller: nameController,
            validator: (value) => null,
          ),
          CustomTextField(
              label: Text("Wysokość"),
              controller: heightController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value == "") {
                  return "Podaj wysokość podkładu";
                }
                return null;
              }),
          CustomTextField(
              label: Text("Szerokość"),
              controller: widthController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value == "") {
                  return "Podaj szerokość podkładu";
                }
                return null;
              }),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: OutlinedButton(
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
                  widget.saveFormat(
                    SheetFormat(
                      name: nameController.text,
                      width: double.tryParse(widthController.text) ?? 0,
                      height: double.tryParse(heightController.text) ?? 0,
                    ),
                  );
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
