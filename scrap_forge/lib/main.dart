import 'package:flutter/material.dart';

import 'package:scrap_forge/pages/home.dart';
import 'package:scrap_forge/pages/loading.dart';

import 'package:scrap_forge/pages/measurement_hub.dart';
import 'package:scrap_forge/pages/product_editor.dart';

Future<void> main() async {
  return runApp(
    MaterialApp(
      // initialRoute: '/productEditor',
      initialRoute: '/measure',
      // initialRoute: '/home',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(
              themeData: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.red,
                    background: Colors.grey[900],
                    onBackground: Colors.white,
                    primary: Colors.red[600],
                    onPrimary: Colors.white,
                    primaryContainer: Colors.orange,
                    secondary: Colors.grey[900],
                    onSecondary: Colors.white,
                    tertiary: Colors.amber,
                    tertiaryContainer: Colors.amberAccent),
                textTheme: const TextTheme(
                  displayLarge: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                  displayMedium: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.normal,
                  ),
                  displaySmall: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
        '/productEditor': (context) => ProductEditor(),
        '/measure': (context) => MeasurementHub(),
        // '/framingTool': (context) => FramingTool(),
        // '/measure': (context) => MeasureTool()
      },
      // home: MeasureTool(),
    ),
  );
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
