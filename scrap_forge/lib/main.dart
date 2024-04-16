import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrap_forge/db_entities/app_settings.dart';
import 'package:scrap_forge/isar_service.dart';
import 'package:scrap_forge/pages/home.dart';
import 'package:scrap_forge/pages/loading.dart';
import 'package:scrap_forge/pages/measurement_hub.dart';
import 'package:scrap_forge/pages/product_editor.dart';
import 'package:scrap_forge/pages/product_gallery.dart';
import 'package:scrap_forge/pages/product.dart';
import 'package:scrap_forge/pages/settings.dart';
import 'package:scrap_forge/utils/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  return runApp(const ScrapForgeApp());
}

class ScrapForgeApp extends StatefulWidget {
  const ScrapForgeApp({super.key});

  @override
  State<ScrapForgeApp> createState() => _ScrapForgeAppState();
}

class _ScrapForgeAppState extends State<ScrapForgeApp> {
  AppSettings appSettings = AppSettings();

  @override
  void initState() {
    super.initState();

    getAppSettings();
    checkPermissions(Permission.camera);
    checkPermissions(Permission.photos);
    checkPermissions(Permission.storage);
  }

  Future<void> getAppSettings() async {
    final IsarService isar = IsarService();

    AppSettings appSettings = await isar.getAppSettings() ??
        await () async {
          AppSettings settings = AppSettings();
          await isar.saveSettings(settings);
          return settings;
        }();

    setState(() {
      this.appSettings = appSettings;
    });
  }

  void updateSettings(AppSettings newSettings) {
    setState(() {
      appSettings = newSettings;
    });
    saveSettings(newSettings);
  }

  Future<void> saveSettings(AppSettings newSettings) async {
    final IsarService isar = IsarService();
    await isar.saveSettings(newSettings);
  }

  Future<void> checkPermissions(Permission permission) async {
    await permission.request();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('pl'), Locale('en')],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/editProduct': (context) => ProductEditor(
              context: context,
              defaultSizeUnit: appSettings.defaultSizeUnit,
            ),
        '/product': (context) => ProductPage(context: context),
        '/measure': (context) => MeasurementHub(
              sheetFormat: appSettings.defaultSheetFormat,
              availableSheetFormats: Map.fromEntries([
                SheetFormat.a3,
                SheetFormat.a4,
                SheetFormat.a5,
                ...appSettings.customSheetFormats,
              ].map((e) => MapEntry(e.name, e))),
              framingQuality: appSettings.framingQuality,
              boundingQuality: appSettings.boundingQuality,
            ),
        '/products': (context) => ProductGallery(context: context),
        '/loading': (context) => const Loading(),
        '/settings': (context) => Settings(
              appSettings: appSettings,
              updateSettings: updateSettings,
            ),
      },
    );
  }
}
