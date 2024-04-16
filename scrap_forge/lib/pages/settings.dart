import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/theme_manager.dart';
import 'package:scrap_forge/widgets/dialogs/custom_formats.dart';
import 'package:scrap_forge/widgets/dialogs/format_selection_menu.dart';
import 'package:scrap_forge/widgets/dialogs/measurement_quality_menu.dart';
import 'package:scrap_forge/widgets/settings_section.dart';

class Settings extends StatefulWidget {
  final AppSettings appSettings;
  final ValueSetter<AppSettings> updateSettings;

  const Settings({
    super.key,
    required this.appSettings,
    required this.updateSettings,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool themeIsDark = ThemeManager.themeIsDark();
  final defaultSizeUnitController = TextEditingController();
  Map<String, SheetFormat> customFormats = {};
  final Map<String, SheetFormat> baseFormats = {
    "A3": SheetFormat.a3,
    "A4": SheetFormat.a4,
    "A5": SheetFormat.a5,
  };

  @override
  void initState() {
    super.initState();
    customFormats = formatsAsMap([...widget.appSettings.customSheetFormats]);
  }

  Map<String, SheetFormat> formatsAsMap(List<SheetFormat> formatList) {
    return formatList.asMap().map((key, value) => MapEntry(value.name, value));
  }

  Future<void> _displayCustomFormatsMenu() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return CustomFormats(
          baseFormats: baseFormats,
          customFormats: customFormats,
          setFormats: (editedFormats) {
            SheetFormat format = widget.appSettings.defaultSheetFormat;
            if (!baseFormats.containsKey(format.name) &&
                !editedFormats.containsKey(format.name)) {
              format = SheetFormat.a4;
            }
            widget.updateSettings(
              widget.appSettings
                ..customSheetFormats = editedFormats.values.toList()
                ..defaultSheetFormat = format,
            );
            setState(() {
              customFormats = editedFormats;
            });
          },
        );
      },
    );
  }

  Future<void> _displayDefaultFormatMenu() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return FormatSelectionMenu(
            formatOptions: Map.fromEntries(
              [...baseFormats.entries, ...customFormats.entries],
            ),
            currentFormat: widget.appSettings.defaultSheetFormat,
            setFormat: (value) {
              widget.updateSettings(
                widget.appSettings..defaultSheetFormat = value,
              );
            });
      },
    );
  }

  Future<void> _displayMeasurementQualityMenu(
      {quality, setQuality, header}) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return MeasurementQualityMenu(
          currentQuality: quality,
          setQuality: setQuality,
          header: header,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width * 0.95;
    MaterialStateProperty<Color> foregroundColor =
        MaterialStateProperty.resolveWith(
            (states) => theme.colorScheme.onPrimary);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Ustawienia"),
        actions: const [],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettingsSection(
                header: const Text('Wygląd aplikacji'),
                children: [
                  SwitchListTile(
                    title: const Text('Ciemny motyw'),
                    activeColor: Colors.red,
                    value: widget.appSettings.darkMode,
                    onChanged: (val) {
                      AppSettings settings = widget.appSettings..darkMode = val;

                      widget.updateSettings(settings);
                    },
                  ),
                ],
              ),
              SettingsSection(
                header: const Text('Narzędzie pomiarowe'),
                children: [
                  TextButton(
                    onPressed: () => _displayMeasurementQualityMenu(
                      quality: widget.appSettings.framingQuality,
                      setQuality: (value) {
                        widget.updateSettings(
                          widget.appSettings..framingQuality = value,
                        );
                      },
                      header:
                          const Text("Wybierz jakość poszukiwania podkładu:"),
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                        theme.colorScheme.onSecondary,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dokładność poszukiwania podkładu:"),
                            Text(
                              widget.appSettings.framingQuality.label,
                              textScaleFactor: 0.9,
                              style: TextStyle(
                                  color: theme.colorScheme.onSecondary),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _displayMeasurementQualityMenu(
                      quality: widget.appSettings.boundingQuality,
                      setQuality: (value) {
                        widget.updateSettings(
                            widget.appSettings..boundingQuality = value);
                      },
                      header:
                          const Text("Wybierz jakość poszukiwania przedmiotu:"),
                    ),
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                        theme.colorScheme.onSecondary,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dokładność poszukiwania przedmiotu:"),
                            Text(
                              widget.appSettings.boundingQuality.label,
                              textScaleFactor: 0.9,
                              style: TextStyle(
                                  color: theme.colorScheme.onSecondary),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _displayDefaultFormatMenu,
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                        theme.colorScheme.onSecondary,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Domyślny format podkładu:"),
                            Text(
                              widget.appSettings.defaultSheetFormat.name,
                              textScaleFactor: 0.9,
                              style: TextStyle(
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _displayCustomFormatsMenu,
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                        theme.colorScheme.onSecondary,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Własne formaty podkładu:"),
                        Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsSection(
                header: const Text('Edytor produktów'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * 0.4,
                          child: const Text("Domyślna jednostka długości"),
                        ),
                        Flexible(
                          child: DropdownMenu<SizeUnit>(
                              inputDecorationTheme: InputDecorationTheme(
                                contentPadding: const EdgeInsets.all(20),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: theme.colorScheme.outline,
                                      width: 1),
                                ),
                              ),
                              dropdownMenuEntries: [
                                DropdownMenuEntry(
                                    style: ButtonStyle(
                                      foregroundColor: foregroundColor,
                                    ),
                                    value: SizeUnit.millimeter,
                                    label: "mm"),
                                DropdownMenuEntry(
                                    style: ButtonStyle(
                                      foregroundColor: foregroundColor,
                                    ),
                                    value: SizeUnit.centimeter,
                                    label: "cm"),
                                DropdownMenuEntry(
                                  style: ButtonStyle(
                                    foregroundColor: foregroundColor,
                                  ),
                                  value: SizeUnit.meter,
                                  label: "m",
                                ),
                              ],
                              initialSelection:
                                  widget.appSettings.defaultSizeUnit,
                              controller: defaultSizeUnitController,
                              onSelected: (value) {
                                widget.updateSettings(
                                  widget.appSettings
                                    ..defaultSizeUnit =
                                        value ?? SizeUnit.millimeter,
                                );
                              }),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
