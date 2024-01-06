import 'package:flutter/material.dart';
import 'package:scrap_forge/main.dart';
import 'package:scrap_forge/widgets/theme_manager.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool themeIsDark = ThemeManager.themeIsDark();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            ThemeManager.toggleTheme(themeIsDark);
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
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wygląd aplikacji:',
                        textScaleFactor: 1.1,
                      ),
                      SwitchListTile(
                          activeColor: Colors.red,
                          value: themeIsDark,
                          onChanged: (val) {
                            setState(() {
                              themeIsDark = val;
                            });
                            ThemeManager.toggleTheme(val);
                          })
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
