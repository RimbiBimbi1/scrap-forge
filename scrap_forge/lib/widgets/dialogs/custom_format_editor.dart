import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/widgets/custom_text_field.dart';

class CustomFormatEditor extends StatefulWidget {
  final ValueSetter<SheetFormat> saveFormat;
  final SheetFormat? edited;
  final Map<String, SheetFormat> formats;
  const CustomFormatEditor({
    super.key,
    required this.saveFormat,
    this.edited,
    required this.formats,
  });

  @override
  State<CustomFormatEditor> createState() => _CustomFormatEditor();
}

class _CustomFormatEditor extends State<CustomFormatEditor> {
  TextEditingController nameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController widthController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.edited?.name ?? "";
    heightController.text = (widget.edited?.height.toInt() ?? "").toString();
    widthController.text = (widget.edited?.width.toInt() ?? "").toString();
  }

  String? nameValidator(String? name) {
    if (name == null) {
      return "Format musi mieć nazwę";
    }
    if (name.isEmpty || name.length > 12) {
      return "Nazwa musi mieć 1-12 znaków";
    }
    if ((name != widget.edited?.name) && widget.formats.containsKey(name)) {
      return "Istnieje już inny format o podanej nazwie";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.edited != null
          ? "Edytuj format ${widget.edited!.name}:"
          : "Dodaj format:"),
      titlePadding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      content: Form(
        key: _formKey,
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          shrinkWrap: true,
          children: [
            CustomTextField(
              label: const Text("Nazwa"),
              controller: nameController,
              validator: nameValidator,
            ),
            CustomTextField(
                label: const Text("Wysokość (w mm)"),
                type: TextInputType.number,
                controller: heightController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value == "") {
                    return "Podaj wysokość formatu";
                  }
                  return null;
                }),
            CustomTextField(
                label: const Text("Szerokość w mm"),
                type: TextInputType.number,
                controller: widthController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value == "") {
                    return "Podaj szerokość formatu";
                  }
                  return null;
                }),
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
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    int w = int.tryParse(widthController.text) ?? 0;
                    int h = int.tryParse(heightController.text) ?? 0;
                    widget.saveFormat(
                      SheetFormat(
                        name: nameController.text,
                        width: min(w, h),
                        height: max(w, h),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
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
