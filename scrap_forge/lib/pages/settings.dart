import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/db_entities/product.dart';
import 'package:scrap_forge/utils/theme_manager.dart';
import 'package:scrap_forge/widgets/dialogs/custom_formats.dart';
import 'package:scrap_forge/widgets/dialogs/default_format_selection.dart';
import 'package:scrap_forge/widgets/dialogs/measurement_quality_menu.dart';
import 'package:scrap_forge/widgets/settings_section.dart';

class Settings extends StatefulWidget {
  final AppSettings appSettings;
  final ValueSetter<AppSettings> updateSettings;
  final ValueSetter<AppSettings> saveSettings;

  const Settings({
    super.key,
    required this.appSettings,
    required this.updateSettings,
    required this.saveSettings,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool themeIsDark = ThemeManager.themeIsDark();
  AppSettings appSettings = AppSettings();
  final defaultSizeUnitController = TextEditingController();
  SheetFormat tempFormat = SheetFormat.a4;

  @override
  void initState() {
    super.initState();
    appSettings = widget.appSettings;
    tempFormat = widget.appSettings.defaultSheetFormat;
  }

  Future<void> _displayCustomFormatsMenu() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return CustomFormats(
          customFormats: appSettings.customSheetFormats,
          setFormats: (formatList) {
            setState(() {
              appSettings = appSettings..customSheetFormats = formatList;
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
        return DefaultFormatMenu(
          formatOptions: [
            SheetFormat.a3,
            SheetFormat.a4,
            SheetFormat.a5,
            ...appSettings.customSheetFormats
          ],
          currentFormat: appSettings.defaultSheetFormat,
          setFormat: (value) {
            setState(() {
              appSettings = appSettings..defaultSheetFormat = value;
            });
          },
        );
      },
    );
  }

  Future<void> _displayMeasurementQualityMenu({quality, setQuality}) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return MeasurementQualityMenu(
          currentQuality: quality,
          setQuality: setQuality,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            widget.updateSettings(appSettings);
            widget.saveSettings(appSettings);
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
                    value: appSettings.darkMode,
                    onChanged: (val) {
                      AppSettings settings = widget.appSettings..darkMode = val;
                      // settings.darkMode = val;
                      setState(() {
                        appSettings = settings;
                        widget.updateSettings(settings);
                      });
                      ThemeManager.toggleTheme(val);
                    },
                  ),
                ],
              ),
              SettingsSection(
                header: const Text('Narzędzie pomiarowe'),
                children: [
                  TextButton(
                    onPressed: () => _displayMeasurementQualityMenu(
                      quality: appSettings.framingQuality,
                      setQuality: (value) {
                        setState(() {
                          appSettings = appSettings..framingQuality = value;
                        });
                      },
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
                              appSettings.framingQuality.label,
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
                      quality: appSettings.boundingQuality,
                      setQuality: (value) {
                        setState(() {
                          appSettings = appSettings..boundingQuality = value;
                        });
                      },
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
                              appSettings.boundingQuality.label,
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
                              appSettings.defaultSheetFormat.name,
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
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                    value: SizeUnit.millimeter, label: "mm"),
                                DropdownMenuEntry(
                                    value: SizeUnit.centimeter, label: "cm"),
                                DropdownMenuEntry(
                                  value: SizeUnit.meter,
                                  label: "m",
                                ),
                              ],
                              initialSelection: appSettings.defaultSizeUnit,
                              controller: defaultSizeUnitController,
                              onSelected: (value) {
                                setState(() {
                                  appSettings = appSettings
                                    ..defaultSizeUnit =
                                        value ?? SizeUnit.millimeter;
                                });
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
