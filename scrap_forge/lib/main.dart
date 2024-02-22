import 'package:flutter/material.dart';
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
      this.appSettings = newSettings;
    });
    saveSettings(newSettings);
  }

  Future<void> saveSettings(AppSettings newSettings) async {
    final IsarService isar = IsarService();
    await isar.saveSettings(newSettings);
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
      // locale: const Locale('pl'),
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
              // saveSettings: saveSettings,
            ),
      },
    );
  }
}



// void main() {
//   runApp(BaseflowPluginExample(
//       pluginName: 'Permission Handler',
//       githubURL: 'https://github.com/Baseflow/flutter-permission-handler',
//       pubDevURL: 'https://pub.dev/packages/permission_handler',
//       pages: [PermissionHandlerWidget.createPage()]));
// }

// ///Defines the main theme color
// final MaterialColor themeMaterialColor =
//     BaseflowPluginExample.createMaterialColor(
//         const Color.fromRGBO(48, 49, 60, 1));

// /// A Flutter application demonstrating the functionality of this plugin
// class PermissionHandlerWidget extends StatefulWidget {
//   /// Create a page containing the functionality of this plugin
//   static ExamplePage createPage() {
//     return ExamplePage(
//         Icons.location_on, (context) => PermissionHandlerWidget());
//   }

//   @override
//   _PermissionHandlerWidgetState createState() =>
//       _PermissionHandlerWidgetState();
// }

// class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ListView(
//           children: Permission.values
//               .where((permission) {
//                   return permission != Permission.unknown &&
//                       permission != Permission.mediaLibrary &&
//                       permission != Permission.photosAddOnly &&
//                       permission != Permission.reminders &&
//                       permission != Permission.bluetooth &&
//                       permission != Permission.appTrackingTransparency &&
//                       permission != Permission.criticalAlerts;
//               })
//               .map((permission) => PermissionWidget(permission))
//               .toList()),
//     );
//   }
// }

// /// Permission widget containing information about the passed [Permission]
// class PermissionWidget extends StatefulWidget {
//   /// Constructs a [PermissionWidget] for the supplied [Permission]
//   const PermissionWidget(this._permission);

//   final Permission _permission;

//   @override
//   _PermissionState createState() => _PermissionState(_permission);
// }

// class _PermissionState extends State<PermissionWidget> {
//   _PermissionState(this._permission);

//   final Permission _permission;
//   PermissionStatus _permissionStatus = PermissionStatus.denied;

//   @override
//   void initState() {
//     super.initState();

//     _listenForPermissionStatus();
//   }

//   void _listenForPermissionStatus() async {
//     final status = await _permission.status;
//     setState(() => _permissionStatus = status);
//   }

//   Color getPermissionColor() {
//     switch (_permissionStatus) {
//       case PermissionStatus.denied:
//         return Colors.red;
//       case PermissionStatus.granted:
//         return Colors.green;
//       case PermissionStatus.limited:
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         _permission.toString(),
//         style: Theme.of(context).textTheme.bodyLarge,
//       ),
//       subtitle: Text(
//         _permissionStatus.toString(),
//         style: TextStyle(color: getPermissionColor()),
//       ),
//       trailing: (_permission is PermissionWithService)
//           ? IconButton(
//               icon: const Icon(
//                 Icons.info,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 checkServiceStatus(
//                     context, _permission as PermissionWithService);
//               })
//           : null,
//       onTap: () {
//         requestPermission(_permission);
//       },
//     );
//   }

//   void checkServiceStatus(
//       BuildContext context, PermissionWithService permission) async {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text((await permission.serviceStatus).toString()),
//     ));
//   }

//   Future<void> requestPermission(Permission permission) async {
//     final status = await permission.request();

//     setState(() {
//       print(status);
//       _permissionStatus = status;
//       print(_permissionStatus);
//     });
//   }
// }
