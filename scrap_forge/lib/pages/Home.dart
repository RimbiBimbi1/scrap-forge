import 'package:flutter/material.dart';
import 'package:scrap_forge/isar_service.dart';

// import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  final ThemeData themeData;
  final dbService = IsarService();

  Home({super.key, required this.themeData});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Future<void> requestAccess() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.camera,
  //     Permission.manageExternalStorage,
  //   ].request();
  //   if (statuses.entries.)
  // }

  // @override
  // void initState() {
  //   requestAccess();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Moja kuźnia"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // child: Image(image: AssetImage('assets/40.jpg')),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("projekt1\n\n"),
                    Text("projekt2\n\n"),
                    Text("projekt3\n\n"),
                  ],
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: [
                      Container(
                        child: Text("Projekty"),
                      ),
                      Container(
                        child: Text("Materiały"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.grey[900],
        //   // elevation: 1.0,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: [
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.menu),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.account_circle_sharp),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //         IconButton(
        //           onPressed: () {},
        //           icon: const Icon(Icons.add),
        //           color: Colors.white,
        //           iconSize: 30.0,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
