import 'package:flutter/material.dart';
import 'package:scrap_forge/db_entities/appSettings.dart';
import 'package:scrap_forge/widgets/settings_section.dart';
import 'package:scrap_forge/widgets/theme_manager.dart';

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

  @override
  void initState() {
    super.initState();
    this.appSettings = widget.appSettings;
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
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
                        this.appSettings = settings;
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: width * 0.4,
                          child: const Text("Dokładność odszukiwania kartki")),
                      DropdownMenu<MeasurementToolQuality>(
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: theme.colorScheme.outline, width: 1),
                          ),
                        ),
                        initialSelection: appSettings.framingQuality,
                        dropdownMenuEntries: MeasurementToolQuality.values
                            .map(
                              (q) =>
                                  DropdownMenuEntry(value: q, label: q.label),
                            )
                            .toList(),
                        onSelected: (quality) {
                          if (quality != null &&
                              appSettings.framingQuality != quality) {
                            setState(() {
                              appSettings = appSettings
                                ..framingQuality = quality;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          width: width * 0.4,
                          child:
                              const Text("Dokładność odszukiwania przedmiotu")),
                      DropdownMenu<MeasurementToolQuality>(
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: theme.colorScheme.outline, width: 1),
                          ),
                        ),
                        initialSelection: appSettings.boundingQuality,
                        dropdownMenuEntries: MeasurementToolQuality.values
                            .map(
                              (q) =>
                                  DropdownMenuEntry(value: q, label: q.label),
                            )
                            .toList(),
                        onSelected: (quality) {
                          if (quality != null &&
                              appSettings.boundingQuality != quality) {
                            setState(() {
                              appSettings = appSettings
                                ..boundingQuality = quality;
                            });
                          }
                        },
                      )
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Własne formaty tła:"),
                        Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Domyślny format tła:"),
                        Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
